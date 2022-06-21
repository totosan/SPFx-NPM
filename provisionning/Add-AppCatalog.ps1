Connect-PnPOnline -Url "https://dev.sharepoint.com" -UseWebLogin

Add-PnPSiteCollectionAppCatalog -Site "https://gdev.sharepoint.com/sites/uwdev"
Add-PnPSiteCollectionAppCatalog -Site "https://gdev.sharepoint.com/sites/mmdev"