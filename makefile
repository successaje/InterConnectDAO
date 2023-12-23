# Phony targets (targets that are not files)
.PHONY: all

# Targets
all: build


# Run tests
test:

.PHONY: webink
.SILENT: webink

# Deploy the DAO contract
deploy:
	$(eval icdaoCanisterID=$(shell dfx canister id icdao))
	echo icdaoCanisterID = $(icdaoCanisterID)
	dfx deploy icdao --argument="(principal \"$(icdaoCanisterID)\", record { \"_name\" = \"icdao\"; \"_symbol\" = \"icdao\"; \"_decimals\" = 0 : nat; \"_initialSupply\" = 1000000000000 : nat; }) " 
	# dfx deploy icdao --argument="( 
	#     principal $(icdaoCanisterID),	
	#  	  record { \"_name\" = \"icdao\"; \"_symbol\" = \"icdao\"; \"_decimals\" = 0 : nat; \"_initialSupply\" = 1000000000000 : nat; }
	# )"
	$(eval icdaoCanisterID=$(shell dfx canister id icdao))
	$(eval candidID=$(shell dfx canister id __Candid_UI))
	# Copy declarations into /declarations
	echo icdaoCanisterID = $(icdaoCanisterID)
	@echo "http://127.0.0.1:8000/?canisterId=$(candidID)&id=$(icdaoCanisterID)"

.PHONY: clean-
.SILENT: clean
clean:
	rm -rf ./.dfx/
	rm -rf ./node_modules/
	rm -rf ./src/declarations/
