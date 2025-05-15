.PHONY: init apply destroy

IMAGE  := ec2-auto-shutdown
VOLUME := ec2state

init:
	docker build -t $(IMAGE) .

apply:
	docker run --rm -it \
	  -e AWS_ACCESS_KEY_ID \
	  -e AWS_SECRET_ACCESS_KEY \
	  -e AWS_REGION \
	  -v $(VOLUME):/app/state \
	  $(IMAGE) apply

destroy:
	docker run --rm -it \
	  -e AWS_ACCESS_KEY_ID \
	  -e AWS_SECRET_ACCESS_KEY \
	  -e AWS_REGION \
	  -v $(VOLUME):/app/state \
	  $(IMAGE) destroy
