#! /bin/bash

# Setting `LC_ALL` to the particular value “C” is a simple yet powerful way to force the locale to use the default language while
# using byte-wise sorting.
LC_ALL=C
PATH=/usr/bin/:/bin/

throw_error() {
	echo "ERROR: $1";
	
	# Exit the script with exit code 1
	exit 1;
}

# Check the currently installed version silently (discarding both the STDOUT and STDERR messages), and throw an error if in case it isn't functional
grep --version &> /dev/null || throw_error "grep having issues!"
sed --version &> /dev/null || throw_error "sed having issues!"
sort --version &> /dev/null || throw_error "sort having issues!"

# Check if a package is available on the system, and  if yes, check if it meets the minimum version requiremenrs
check_package_compatibility() {
	# Check if the specified binary ($1) is present in the specified PATH
	if ! type -p $1 &> /dev/null
	then
		throw_error "$1 not found"
	fi

	# Trap the version of the package in question, using regexp
	v=$($1 --version 2>&1 | grep -E -o '[0-9]+\.[0-9\.]+[a-z]*' | head -n1)

	# Check if the trapped version number is higher than the minimum version required ($2)
	if printf '%s\n' $2 $v | sort --version-sort --check &>/dev/null
	then
		printf "OK: $1 satisfies the minimum version requirements\n"; return 0;
	else
		# Not calling throw_error() function here so that the script shows results for all packages before exiting
		printf "ERROR: $1 needs to be upgraded to minimum version $2\n"
		return 1;
	fi
}

check_kernel_version() {
	# Trap the Linux kernel version running
	kv=$(uname -r | grep -E -o '^[0-9\.]+')
	
	# Check if the trapped kernel version is higher than the minimum version required ($1)
	if printf '%s\n' $1 $kv | sort --version-sort --check &>/dev/null
	then
		printf "OK: Linux Kernel $kv satisfies the minimum version requirements\n"; return 0;
	else
		printf "ERROR: Linux Kernel $kv needs to be upgraded to minimum version $1\n";
		return 1;
	fi
}

# Requirements as specified by LFS v12
check_package_compatibility sort 7.0 || throw_error "invalid sort flag used!"
check_package_compatibility bash 3.2
check_package_compatibility ldd 2.13.1
check_package_compatibility bison 2.7
check_package_compatibility diff 2.8.1
check_package_compatibility find 4.2.31
check_package_compatibility gawk 4.0.1
check_package_compatibility gcc 5.1
check_package_compatibility grep 2.5.1a
check_package_compatibility gzip 1.3.12
check_package_compatibility m4 1.4.10
check_package_compatibility make 4.0
check_package_compatibility patch 2.5.4
check_package_compatibility perl 5.8.8
check_package_compatibility python3 3.4
check_package_compatibility sed 4.1.5
check_package_compatibility tar 1.22
check_package_compatibility texi2any 5.0
check_package_compatibility xz 5.0.0

check_kernel_version 4.14

if mount | grep -q 'devpts on /dev/pts' && [ -e /dev/ptmx ]
then
	echo "OK: Kernel supports UNIX 98 PTY";
else 
	echo "ERROR: Kernel does NOT support UNIX 98 PTY";
fi

# The LFS book v12 also suggests us to verify aliases for certain commands, but in my case, they weren't implemented as symlinks, but were rather
# triggered in another script located in /etc/alternatives/ directory. Some of them were readable, but others didn't have ASCII characters to verify
# the scripts, hence that segment is not included!
