DAContextMenuTableViewController
================================

A UITableViewController subclass with "more" accessory view, that looks and behaves similarly to the one in the native mail app.

![Alt text](DAContextMenuTableViewController.gif)

I know there is a willTransitionToState: method where I could create a custom accessoryView with "More" button. 
But theres is no width for Delete button (which may vary for different languages) and no animation duration, so custom editing view seemed a better sollution for me.


TODO
==============

- bounce animation
- better handling of rotation animation
- iOS7-like look for iOS 6 context menu action sheet
