# High Sierra Hackintosh
### 5960X
### GTX 670 
### GTX 570
### 32GB Kingston DDR4 2133Mhz

## Resources

#### [Main Guide](https://www.tonymacx86.com/threads/how-to-extend-the-imac-pro-to-x99-successful-build-extended-guide.227001/#post-1542618)
#### [Creating Boot Image](https://hackintosher.com/guides/make-macos-flash-drive-installer/)
#### [Install/boot media/usb/disk creation instructions](https://hackintosher.com/guides/macos-high-sierra-hackintosh-install-clover-walkthrough/)
#### [Clover Configurator v5.4.4 - CCC](https://www.macupdate.com/app/mac/61090/clover-configurator)
#### [Clover EFI installer (not needed if using EFI files from main guide creator)](https://sourceforge.net/projects/cloverefiboot/files/latest/download)
#### [X99D Deluxe I/II EFI instructions](https://medium.com/@salbito/efi-drivers-kexts-400b08ccafb8)
#### [Windows NTFS to HFS+ Drive Erase Help from OSX recovery](https://mycyberuniverse.com/how-fix-mediakit-reports-not-enough-space-on-device.html)
#### [If you get could not be installed error after selecting target install drive in clover on reboot](https://www.tonymacx86.com/threads/solved-macos-could-not-be-installed-on-your-computer-installer-resources-error.263961/page-4)
## Notes
#### MMTool instructions require renaming MMTool.exe to MMTool_A4 exactly, capitalization is important, and using mmtool v5.0.0.7. Ubu tells you mmtool_a4.exe for v5.0.0.7 or mmtool_a5.exe for v5.2.0.2x but the only combination I could get working was v5.0.0.7 with MMTool_A4 as the filename
#### copy install files on target machine manually with [Ylx's command](https://www.tonymacx86.com/threads/solved-macos-could-not-be-installed-on-your-computer-installer-resources-error.263961/page-4) to fix could not be installed error after selecting target install drive in clover on reboot
* cp -rf /Volumes/{the name of your install media}/Install\ macOS\ {your OS Version}.app/Contents/SharedResources/* /Volumes/{your target installation volume}/macOS\ install\ data/
* Thank you so much everyone! Expecially @Ylx ! I spent several days trying to get High Sierra on my new Hackintosh. The ./startosinstall didn't work after several attempts. So I tried Ylx's method. It took me a while to figure out his instructions but once I did, install went flawlessly. If you are total noob like me, here is what I did step by step(as best as I can remember).
* Follow High Sierra fresh install guide to create USB boot drive
* Insert and boot from USB
* Run "Install macOS High Sierra" on clover screen
* Again following the guide- format drive, Install OS, Select langue, Select drive...
* system will restart.
* Once back in clover select "High Sierra" drive
* Once you reach the "Could not install MacOS" screen open "terminal" under "Utilities" in the top banner
* Run Ylx's command...and wait for it to complete. Took about 5 min. for me
* Restart
* On clover screen select Restart
* I restarted a gain for good measure
* On clover screen select "High Sierra"
* System will restart again, select "High Sierra"
* I believe this is when the installation completed for me. Yay!
