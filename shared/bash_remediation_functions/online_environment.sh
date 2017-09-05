# Function to check if we are remediating an online environment
# Use this function to idenfity an on-line remediation and perform
# changes suitable for runtime only.
# 
# An online environment is one in which the binaries from filesystem
# are running. Such environment can be a:
# - Bare metal machine
# - Virtual machine
# - Running container
# 
# We use inode number of root directory to verify if we are online.
# If inode number of root directory is not 2 we are in a chrooted environment,
# and we are very likely remediating one of the following environemnts:
# - Anaconda install
# - Chrooted filesystem
# - Container image build
# - Running container
#
# Which are all offline environments, except the running container.
# 

function online_environment {
    inode=$(ls -di / | cut -d ' ' -f1)

    if [ $inode -eq "2" ]
    then
        return 0
    else
        return 1
    fi
}
