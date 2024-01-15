provider "aws" {
  region = var.aws_region
}

provider "archive" {}

#hier wird unsere main.py verpackt in die zip 
data "archive_file" "zip" {
  type        = "zip"
  source_file = "${path.module}/../main.py"
  output_path = "main_lambda.zip"
}

# die policy das ganze mus in die data verpackt 
#man könnt es auc als resourde machen 
data "aws_iam_policy_document" "policy" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}
# es wird aus diesem block eine json rolle erstellt und unsere wo wir erstellt haben 
#wird auch hier intergried 
resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = "${data.aws_iam_policy_document.policy.json}"
}

# die polycy arn besteht bereits es ist eine basisrolle und diese fügen wir ein 
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# die eigentliche Lamda Function man kann das auch über ein modul erstellen 
# terraform erkennt die veränderung durch das hasching sha256
resource "aws_lambda_function" "lambda" {
  function_name = "main"
  filename         = "${data.archive_file.zip.output_path}"
  source_code_hash = "${data.archive_file.zip.output_base64sha256}"

   role    = "${aws_iam_role.iam_for_lambda.arn}"
  handler = "main.handler"   #name der function im main.py 
  runtime = "python3.11"

  environment {
    variables = {
      NAME = "Muhammed"
    }
  }
}

# wenn man hard codet kann man random_pet resource nutzen welche zufällige namen generiert 