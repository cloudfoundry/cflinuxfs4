ARCH := x86_64
NAME := cflinuxfs4
BASE := ubuntu:jammy
BUILD := $(NAME).$(ARCH)

all: $(BUILD).tar.gz

compat:
	if [ -z "$(version)" ]; then >&2 echo "version must be set" && exit 1; fi
	docker build . \
		--file compat.Dockerfile \
		--build-arg "base=cloudfoundry/cflinuxfs4:$(version)" \
		--build-arg packages="`cat "packages/cflinuxfs4-compat" 2>/dev/null`" \
  	--no-cache "--iidfile=$(BUILD)-compat.iid"

	docker run "--cidfile=$(BUILD)-compat.cid" `cat "$(BUILD)-compat.iid"` dpkg -l | tee "packages-list"
	docker export `cat "$(BUILD)-compat.cid"` | gzip > "$(BUILD)-compat.tar.gz"
	docker rm -f `cat "$(BUILD)-compat.cid"`
	rm -f "$(BUILD)-compat.cid" "$(BUILD)-compat.iid"

$(BUILD).iid:
	docker build \
	--build-arg "base=$(BASE)" \
	--build-arg packages="`cat "packages/$(NAME)" 2>/dev/null`" \
	--build-arg locales="`cat locales`" \
	--no-cache "--iidfile=$(BUILD).iid" .

$(BUILD).tar.gz: $(BUILD).iid
	docker run "--cidfile=$(BUILD).cid" `cat "$(BUILD).iid"` dpkg -l | tee "packages-list"
	docker export `cat "$(BUILD).cid"` | gzip > "$(BUILD).tar.gz"
	echo "Rootfs SHASUM: `shasum -a 256 "$(BUILD).tar.gz" | cut -d' ' -f1`" > "receipt.$(BUILD)"
	echo "" >> "receipt.$(BUILD)"
	cat "packages-list" >> "receipt.$(BUILD)"
	docker rm -f `cat "$(BUILD).cid"`
	rm -f "$(BUILD).cid" "packages-list"
