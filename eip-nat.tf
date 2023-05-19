resource "aws_eip" "lb" {
   vpc      = true
}
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.publicsubnets.0.id
}