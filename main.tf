# Provider Configuration
provider "aws" {
  region = "ap-south-1"
}

# VPC Creation
resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
}
resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.example_vpc.id
}

resource "aws_security_group" "windows_sg" {
  depends_on = [aws_vpc.example_vpc]
  vpc_id     = aws_vpc.example_vpc.id

  # Allow RDP (Port 3389) and WinRM (Port 5985) from anywhere
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5985
    to_port     = 5985
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example_instance" {
  depends_on                  = [aws_security_group.windows_sg, aws_subnet.example_subnet, aws_internet_gateway.example_igw, aws_route_table.example_route_table]
  ami                         = "ami-07ef4004db979fcd4"
  instance_type               = "t2.medium"
  key_name                    = "windowssm"
  subnet_id                   = aws_subnet.example_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.windows_sg.id]
  user_data                   = <<-EOF
    <powershell>
Set-ExecutionPolicy RemoteSigned -Scope Process -Force
$url = "https://go.microsoft.com/fwlink/?linkid=2191847"
$outputPath = "C:\users\administrator\downloads\file.zip"
$destination = "C:\users\administrator\downloads\test"
Invoke-WebRequest -Uri $url -OutFile $outputPath
Expand-Archive -Path $outputPath -DestinationPath $destination
$scriptPath = "$destination\AzureMigrateInstaller.ps1"
$inputCommands = @(
    "3",  # Desired scenario
    "1",  # Another choice
    "1",  # Another choice
    "Y"   # Proceed confirmation
)
$inputCommands | Out-File -FilePath "$destination\input.txt" -Encoding ASCII
$process = Start-Process -FilePath "powershell.exe" -ArgumentList "-NoExit", "-File", "$scriptPath" -PassThru  -RedirectStandardInput "$destination\input.txt"
</powershell>
<persist>true</persist>
  EOF


  root_block_device {
    volume_size = 80
  }
}

resource "aws_subnet" "example_subnet" {
  depends_on        = [aws_vpc.example_vpc]
  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
}
resource "aws_route_table" "example_route_table" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_igw.id
  }
}

resource "aws_route_table_association" "example_subnet_association" {
  subnet_id      = aws_subnet.example_subnet.id
  route_table_id = aws_route_table.example_route_table.id
}

output "instance_public_ip" {
  value = aws_instance.example_instance.public_ip
}
