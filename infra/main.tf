provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "terraform-tfstate-grupo12-fiap-2024"
    key    = "infra_sqs/terraform.tfstate"
    region = "us-east-1"
  }
}

#sqs_atualiza_pagamento_pedido
data "aws_lambda_function" "lambda_pagamento_pedido" {
  function_name = "lambda_pagamento_pedido"
}

resource "aws_sqs_queue" "atualiza_pagamento_pedido" {
  name = "sqs_atualiza_pagamento_pedido"
}

resource "aws_lambda_permission" "permission_lambda_pagamento_pedido" {
  statement_id  = "AllowSQSTrigger"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.lambda_pagamento_pedido.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.atualiza_pagamento_pedido.arn
}

resource "aws_lambda_event_source_mapping" "sqs_to_lambda_pagamento_pedido" {
  event_source_arn = aws_sqs_queue.atualiza_pagamento_pedido.arn
  function_name    = data.aws_lambda_function.lambda_pagamento_pedido.function_name
  batch_size       = 10
  enabled          = true
}



#sqs_solicita_pagamento
data "aws_lambda_function" "lambda_sqs_pagamento" {
  function_name = "lambda_sqs_pagamento"
}

resource "aws_sqs_queue" "solicita_pagamento" {
  name = "sqs_solicita_pagamento"
}

resource "aws_lambda_permission" "permission_lambda_sqs_pagamento" {
  statement_id  = "AllowSQSTrigger"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.lambda_sqs_pagamento.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.solicita_pagamento.arn
}

resource "aws_lambda_event_source_mapping" "sqs_to_lambda_sqs_pagamento" {
  event_source_arn = aws_sqs_queue.solicita_pagamento.arn
  function_name    = data.aws_lambda_function.lambda_sqs_pagamento.function_name
  batch_size       = 10
  enabled          = true
}