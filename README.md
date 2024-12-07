This Script will do several things.

It will prompt to add a new host name.
It will prompt to add a user
It will prompt to add a password
It will then add passwordless for sudo group
It will then update
It will install curl, wget , git, qemu-guest-agent
Start the qemu-guest-agent.service
Pull the repo for Webmin
Install Webmin
Clean up files using autoremove

Install git:
```
sudo apt install git -y
```

Get files from Github:
```
git clone https://github.com/diggitytech/Ubuntu-install-Scripts.git
```
Change to directory:
```
cd Ubuntu-install-Scripts
```
Make executable:
```
sudo chmod +x fresh_VM_install.sh
```

Execute:
```
sudo ./fresh_VM_install.sh
```
