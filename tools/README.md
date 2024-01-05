Run docker file:

Navigate to docker file location:

```bash
cd /dfds/aws-modules-rds/tools
```

Build image:

```bash
docker build -t scaffold .
```

Create output folder:

```bash
mkdir auto-generated
```

Run docker:

```bash
docker run -v <absolute-path>/aws-modules-rds/:/input -v <absolute-path>/aws-modules-rds/tools/auto-generated:/output scaffold:latest
```
