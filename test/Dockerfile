# This is a just a Dockerfile for the purpose of testing. We will create a docker image using this Dockerfile and push it to the
# created ECR repository.
FROM alpine:3.11
ARG text
RUN echo $text > text.txt
CMD ["cat", "text.txt"]
