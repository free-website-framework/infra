data "github_repository" "this" {
  name = var.github_repo
}

data "github_branch" "this" {
  repository = var.github_repo
  branch     = var.github_branch
}

resource "null_resource" "package" {
  triggers = {
    branch_sha = data.github_branch.this.sha
  }

  provisioner "local-exec" {
    command = <<-EOT
      rm -rf ${path.module}/build/repo ${path.module}/build/package
      git clone ${data.github_repository.this.ssh_clone_url} -b ${var.github_branch} --depth 1 ${path.module}/build/repo
      docker build \
        -f ./${path.module}/build/Dockerfile \
        --target artifact \
        --platform linux/arm64 \
        --output type=local,dest=${path.module}/build/package \
        --build-arg python_version=${var.python_version} \
        ${path.module}/build
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ${path.module}/build/repo ${path.module}/build/package"
  }
}


resource "archive_file" "package" {
  type        = "zip"
  source_dir  = "${path.module}/build/package"
  output_path = "${path.module}/build/package.zip"
  depends_on  = [null_resource.package]

  provisioner "local-exec" {
    when    = destroy
    command = "rm ${path.module}/build/package.zip"
  }

  lifecycle {
    replace_triggered_by = [null_resource.package]
  }
}
