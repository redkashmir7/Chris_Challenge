from diagrams import Cluster, Diagram
from diagrams.aws.compute import EC2, AutoScaling
from diagrams.aws.network import ELB, Route53
from diagrams.aws.security import CertificateManager

with Diagram("Web Services", show=False):
    dns = Route53("dns")
    web = ELB("load balancer")
    certificate = CertificateManager("ACM")

    with Cluster("Services"):
        svc_group = [EC2("web1"),
                     EC2("web2")]

    autoscaling = AutoScaling("ASG")
    autoscaling >> svc_group

    dns >> web >> autoscaling
    certificate >> web
