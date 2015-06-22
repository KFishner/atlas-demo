provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "us-east-1"
}

resource "atlas_artifact" "consul" {
    name = "KFishner/consul"
    type = "aws.ami"
}

resource "atlas_artifact" "masscan" {
    name = "KFishner/masscan"
    type = "aws.ami"
}

resource "aws_instance" "consul" {
    instance_type = "t2.micro"
    ami = "${atlas_artifact.consul.metadata_full.region-us-east-1}"
    key_name = "kfishner"

    count = "${var.consul_count}"
}

resource "aws_instance" "masscan" {
    instance_type = "t2.micro"
    ami = "${atlas_artifact.masscan.metadata_full.region-us-east-1}"
    key_name = "kfishner"

    count = "${var.masscan_count}"
}

resource "aws_elb" "web" {
    name = "terraform-demo-elb"

    # The same availability zone as our instances
    availability_zones = ["${aws_instance.masscan.*.availability_zone}"]

    listener {
        instance_port = 80
        instance_protocol = "http"
        lb_port = 80
        lb_protocol = "http"
    }

    # The instances are registered automatically
    instances = ["${aws_instance.masscan.*.id}"]
}
