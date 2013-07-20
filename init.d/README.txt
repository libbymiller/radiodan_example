

to add:

sudo cp init.d/say_ip /etc/init.d/
sudo cp init.d/radiodan /etc/init.d/

sudo update-rc.d say_ip defaults
sudo update-rc.d radiodan defaults
to test:
/etc/init.d/say_ip start
/etc/init.d/radiodan start
to remove
sudo update-rc.d say_ip remove
sudo update-rc.d radiodan remove
