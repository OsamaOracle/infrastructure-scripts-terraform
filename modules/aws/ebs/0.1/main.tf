data "aws_instance" "ec2_instance" {
  count       = length(var.instance_ids)
  instance_id = var.instance_ids[count.index]
}

resource "aws_ebs_volume" "ebs" {
  count = length(var.instance_ids)
  availability_zone = element(var.availability_zones, count.index % length(var.availability_zones))
  size = var.data_volume_size
  encrypted = var.data_volume_encrypted
  type = var.data_volume_type

  tags = merge(
    var.common_tags,
    { Name = "${lookup(data.aws_instance.ec2_instance.*.tags[count.index], "Name", data.aws_instance.ec2_instance.*.id[count.index])}-${var.data_volume_name}" },
  )
}

resource "aws_volume_attachment" "_ebs_attachement" {
  count       = length(var.instance_ids)
  device_name = var.data_volume_device_name
  volume_id   = element(aws_ebs_volume.ebs.*.id, count.index)
  instance_id = element(data.aws_instance.ec2_instance.*.id, count.index)
}
