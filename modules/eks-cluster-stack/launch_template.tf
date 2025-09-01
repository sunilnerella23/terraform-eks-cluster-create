resource "aws_launch_template" "custom_launch_template" {
  name = "${var.environment}-eks-custom-launch-template"
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = var.launch_template_volume_size
      volume_type = "gp3"
    }
  }
  # image_id = var.eks_worker_fips_image_id
  metadata_options {
  http_tokens   = "optional" 
}
  user_data = filebase64("${path.module}/configs/custom_userdata.tmpl")
}
