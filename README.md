# Rigel

Rigel is an exploratory project for iOS. It's focused on evaluating  on the viability of using mesh networking and the [Multipeer Connectivity](https://developer.apple.com/library/ios/documentation/MultipeerConnectivity/Reference/MultipeerConnectivityFramework/) framework to improve file downloads.

### Features 

The iOS app simulates a music player with resources available in the cloud.
The uses the Multipeer Connectivity (MC) framework to connect two devices that are close-by. 

When the devices are connected and are requested to download a track, they’ll look for the asset on the local network (other device) as well as on the web (regular download).

It’s currently limited to two devices simultaneously connected.


### Research Project
Rigel was used on the research paper “Download optimisation though file sharing on mobile ad-hoc networks” – by  Cesar Barscevicius.

The paper discusses the impact of this technology being adopted in Resource Constrained Networks (RCN) as well as in areas where Internet coverage isn’t ideal.

Here’s the paper Abstract:

>“Data traffic on mobile devices continues to grow in Brazil, and all around the world. In the next decades, there will be challenges such as implementing mobile data networks in places with little or no access to wired connectivity to the web. The instability of some mobile networks, stacked with the traffic growth of mobile data, leads to the main question of this research project: How to optimize file downloads in flawed networks? The purposed solution studies Resource Constrained Networks  (RCN) and Mobile Ad-hoc Networks (MANET), suggesting the creation of a local file sharing system, in order to improve media files download. This system was developed, as a mobile application for the iOS platform. A sample library with audio media was created to standardise testing of remote and local file downloads. The prototype was tested against several environments, to simulate real case scenario situations. The results found, the graphical analysis with data from different download sources, and the debate on future studies involving the used technology, are also part of this research.”

During the development of the research project mentioned above, very few projects that used MC were found on the web. Rigel source code is available here to allow further discussions on the matter.