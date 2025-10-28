ARCH := x86_64
NAME := cflinuxfs4
BASE := ubuntu:jammy
BUILD := $(NAME).$(ARCH)
COMPAT_BUILD := $(NAME)-compat.$(ARCH)

all: $(BUILD).tar.gz

compat:
	if [ -z "$(version)" ]; then >&2 echo "version must be set" && exit 1; fi

	curl --fail -L -o cflinuxfs4.tar.gz https://github.com/cloudfoundry/cflinuxfs4/releases/download/$(version)/cflinuxfs4-$(version).tar.gz
	gunzip -c cflinuxfs4.tar.gz | docker import - cflinuxfs4-local:$(version)
	rm -f cflinuxfs4.tar.gz

	docker build . \
		--file compat.Dockerfile \
		--build-arg "base=cflinuxfs4-local:$(version)" \
		--build-arg packages="`cat "packages/cflinuxfs4-compat" 2>/dev/null`" \
  	--no-cache "--iidfile=$(COMPAT_BUILD).iid"

	docker run "--cidfile=$(COMPAT_BUILD).cid" `cat "$(COMPAT_BUILD).iid"` dpkg -l
	docker export `cat "$(COMPAT_BUILD).cid"` | gzip > "$(COMPAT_BUILD).tar.gz"
	docker rm -f `cat "$(COMPAT_BUILD).cid"`
	rm -f "$(COMPAT_BUILD).cid" "$(COMPAT_BUILD).iid"

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
