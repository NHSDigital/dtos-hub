# AVD Pool Migration Guide

“Blue” and “Green” refer to the two AVD host pool sets. The active (primary) pool is determined by the virtual_desktop_group_active variable. This is a guide to migrate from one pool set to another. Likely moving forward there will be a pipeline which can do this without needing to manually update the configuration in the code.

Here are a list of the virtual_desktop_group_active status:

- blue means only virtual desktop blue is deployed whilst virtual desktop green is removed.
- green means only virtual desktop green is deployed whilst virtual desktop blue is removed. Users are directed to group green.
- both-with-blue-primary means both virtual desktop groups are deployed, but ONLY the platform users can see group green. All other users will be directed to group blue.
- both-with-green-primary means both virtual desktop groups are deployed, but ONLY the platform users can see group blue. All other users will be directed to group green.
- both-with-blue-primary-but-equal-vms means both virtual desktop groups are deployed with equal VM counts, but ONLY the platform users can see group green. All other users will be directed to group blue.
- both-with-green-primary-but-equal-vms means both virtual desktop groups are deployed with equal VM counts, but ONLY the platform users can see group blue. All other users will be directed to group green.

Green Migration Guide (Blue to Green)

- Set virtual_desktop_group_active = "both-with-blue-primary" to bring Green online while keeping Blue as primary.
- Allow platform users on Green to validate the new Golden image and check tooling.
- Set virtual_desktop_group_active = "both-with-green-primary-but-equal-vms" to balance capacity (to ensure we can fail over minimal downtime)
- Switch primary: set virtual_desktop_group_active = "both-with-green-primary".
- Observe and monitor users on Green ADV.
- Fully cut over: set virtual_desktop_group_active = "green" to retire Blue.
- Rollback (if needed): switch back to blue or both-with-blue-primary.

Blue Migration Guide (Green to Blue)

- Set virtual_desktop_group_active = "both-with-green-primary" to bring Blue online while keeping Green as primary.
- Allow platform users on Blue to validate the new Golden image and check tooling.
- Set virtual_desktop_group_active = "both-with-blue-primary-but-equal-vms" to balance capacity (to ensure we can fail over minimal downtime)
- Switch primary: set virtual_desktop_group_active = "both-with-blue-primary".
- Observe and monitor users on Blue ADV.
- Fully cut over: set virtual_desktop_group_active = "blue" to retire Green.
- Rollback (if needed): switch back to green or both-with-green-primary.
