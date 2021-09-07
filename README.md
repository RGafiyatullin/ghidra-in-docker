Usage:
```shell
docker build -t ghidra-in-docker:latest

docker run \
	-it --name ghidra-$$ \
	-e X_AUTHC_COOKIE=$(xauth list | grep MIT-MAGIC-COOKIE-1 | head -n 1 | awk '{print $3}') \
	-v '/path/to/the-project:/home/user/the-project' \
	ghidra-in-docker:latest
```
