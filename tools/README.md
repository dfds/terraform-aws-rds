Run docker file:

cd /dfds/aws-modules-rds/tools

```
docker build -t scaffold .
```

mkdir auto-generated

```
docker run -v /aws-modules-rds/:/input -v /auto-generated:/output scaffold:latest
```
