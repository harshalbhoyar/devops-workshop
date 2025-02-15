# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a resource
resource "aws_instance" "demo-server" {
    ami           = "ami-0c55b159cbfafe1f0"
    instance_type = "t2.micro"
    key_name = dpp
}
