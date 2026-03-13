ARG python_version=3.14
FROM public.ecr.aws/lambda/python:${python_version} AS builder
WORKDIR /var/task

COPY repo/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt -t ./build
COPY repo/app/ ./build/app/

FROM scratch AS artifact
COPY --from=builder /var/task/build /
