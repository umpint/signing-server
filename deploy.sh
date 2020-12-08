# save your account id into the acountid file - it is a 12 digit number
# you also need to have config and credetials set up and aws tools installed.
# The account in the credentials needs write access to AWS ECR and a repository created called umpint-web
AWS_ACCOUNT_ID=`cat ~/.aws/accountid`
AWS_REGION=`cat ~/.aws/config | grep region | awk '{print $3}'| head -1`
echo "account $AWS_ACCOUNT_ID"
echo "region  $AWS_REGION"

tag=$1

if [ "_$tag" == "_" ];then
	tag=latest
	git tag -f $tag
else
	git tag $tag
fi


aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

docker build -t signing-server -f Dockerfile_aws .
if [ $tag != latest ];then
	docker tag signing-server:latest signing-server:$tag
fi
docker tag signing-server:$tag ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/signing-server:$tag
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/signing-server:$tag
