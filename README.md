nginx Icecast radio station for Openshift RHC Servers
=========================

Usage
-----

To get your custom Icecast radio station  working at OpenShift, you have to do the following:

1. Create a new Openshift "Do-It-Yourself" application.
2. Clone this repository.
    
3. Add a new remote "openshift" (You can find the URL to your git repository on the Openshift application page)
4. Run `git push --force "openshift" master:master`
5. SSH into your gear (With Putty or gitbash) 
6.  `cd $OPENSHIFT_REPO_DIR &&rm -rf new-radiostation && rm -rf misc* && rm -rf www && rm -rf icecast-openshift-free ` 
7. `git clone https://github.com/icecast-in-openshift4free/icecast4free-openshift-radio-rhc.git && mv icecast4free-openshift-radio-rhc new-radiostation && mv "$OPENSHIFT_REPO_DIR/new-radiostation/install nginx-radio internet-centos openshift.sh" "$OPENSHIFT_REPO_DIR/new-radiostation/install-nginx-radio-internet-centos-openshift.sh"` 
8. `chmod 755  "$OPENSHIFT_REPO_DIR/new-radiostation/install-nginx-radio-internet-centos-openshift.sh"`
9. Wait (This may take at least an hour)
    If you want to see "what's going on, you may tail the log file and watch some shell movie ;)
10. `nohup $OPENSHIFT_REPO_DIR/new-radiostation/install-nginx-radio-internet-centos-openshift.sh > $OPENSHIFT_LOG_DIR/install.log & `
    `tail -f $OPENSHIFT_DIY_LOG_DIR/install.log`
11. Open http://appname-namespace.rhcloud.com to verify running
   
12. Open http://appname-namespace.rhcloud.com/radiostation1 to listen to first radiostation.
13. you can  install winamp and edcast  plugin in your pc have a live radiostation.
 * you could download edcast plug from here: https://www.radioking.com/on/knowledgebase/126/Diffuser-avec-Winamp.html or  http://djlab.com/stuff/dj/edcast_winamp_3.1.21.exe
 * So you must install rhc  by this link:
 * https://blog.openshift.com/how-to-install-the-openshift-rhc-client-tools-on-windows/ 
 *and then run :
 *`rhc port-forward -a <app_name>`
 * so you must inter this configuration to your winamp edcast plugin by this photo:
 *![Alt text](http://i.stack.imgur.com/OcJHR.jpg "Configuration to your winamp edcast plugin")
 * And you could see all in this photo
 *![Alt text](http://i.stack.imgur.com/SZciC.jpg  "Configuration to your winamp edcast plugin")
 14. Open http://appname-namespace.rhcloud.com/onair2 to listen to your live  radiostation.
 

 
 
