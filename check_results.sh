#!/usr/bin/bash

# Run the AWS CLI command and store the output in a variable
instances_info=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId, PublicIpAddress, PrivateIpAddress]' --output text)

# Get the first and last machine info
first_instance_info=$(echo "$instances_info" | head -n 1)
last_instance_info=$(echo "$instances_info" | tail -n 1)

# Initialize an array to store the results
results=()

# Loop through each instance except the last one
IFS=$'\n'
for line in $(echo "$instances_info" | sed '$d'); do
	    instance_id=$(echo "$line" | cut -f 1)
	        public_ip=$(echo "$line" | cut -f 2)
		    private_ip=$(echo "$line" | cut -f 3)
		        
		        # Get the next instance's private IP
			    next_instance_info=$(echo "$instances_info" | grep -A 1 "$line" | tail -n 1)
			        next_private_ip=$(echo "$next_instance_info" | cut -f 3)
				    
				    echo "SSH to instance: $instance_id, Public IP: $public_ip, Private IP: $private_ip"
				        ping_result=$(ssh -i "keys/output.pem" ec2-user@"$public_ip" "ping -c 3 -W 5 $next_private_ip" 2>&1)
					    
					    # Check if ping was successful or not
					        if echo "$ping_result" | grep -q "3 received"; then
							        results+=("OK")
								    else
									            results+=("NOK")
										        fi
										done

										# Ping the first instance from the last one
										last_public_ip=$(echo "$last_instance_info" | cut -f 2)
										first_private_ip=$(echo "$first_instance_info" | cut -f 3)
										echo "SSH to instance: $last_instance_info, Public IP: $last_public_ip, Private IP: $first_private_ip"
										ping_result=$(ssh -i "keys/output.pem" ec2-user@"$last_public_ip" "ping -c 3 -W 5 $first_private_ip" 2>&1)
										if echo "$ping_result" | grep -q "3 received"; then
											    results+=("OK")
										    else
											        results+=("NOK")
										fi

										# Print the results
										echo "Results:"
										for ((i=0; i<${#results[@]}; i++)); do
											    echo "Relation $i: ${results[$i]}"
										    done
