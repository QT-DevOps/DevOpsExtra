provider "aws" {
    region      = "us-west-2"
}

provider "aws" {
    region      = "ap-south-1"
    alias       = "mumbai"

}
