package
{
	import flash.display.Sprite;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.system.Security;
	
	public class SimpleStreamingVideoPlayer extends Sprite
	{
		private var nc:NetConnection;
		private var server:String;
		private var stream:String;
		
		private var remoteVideo:Video;
		
		public var videoWidth;
		public var videoHeight;

		public function SimpleStreamingVideoPlayer()
		{
			Security.allowDomain("*");

			if (ExternalInterface.available) 
			{	
				log("ExternalInterface.avaialble");
				
				ExternalInterface.addCallback("start", startStream);
				ExternalInterface.addCallback("disconnect", disconnectStream);
			
				ExternalInterface.call("playerInit");
				ExternalInterface.call("playerEvent");
			}
			
			startStream("rtmp://128.122.151.16/live","ptzcamera.stream");
		}
		
		private function log(message:String) {
			if (ExternalInterface.available) {
				ExternalInterface.call( "console.log" , message);
			}
			trace(message);
		}

		private function startStream(_server:String, _stream:String)
		{
			server = _server;
			stream = _stream;
			
			log("startStream: " + server + " " + stream);
			
			nc = new NetConnection();
			
			nc.addEventListener(NetStatusEvent.NET_STATUS,ncStatus);
			nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			
			nc.connect(server);
		}
		
		private function disconnectStream()
		{								
			log("disconnectStream");
			if (nc.connected) {	
				nc.close();
			}
		}
		
		private function cuePoint(infoObject:Object):void {
			log("cuePoint");
		}
		
		private function metaData(infoObject:Object):void {
			log("metaData");
			
			//setDimensions(infoObject.width, infoObject.height);
			
			/*
			// Make sure it fits on the screen
			var resizeFactor:Number = 1;
			if (video.width > nativeWindows[1].width && video.width - nativeWindows[1].width > video.height - nativeWindows[1].height) {
				resizeFactor = nativeWindows[1].width/video.width;
			} else if (video.height > nativeWindows[1].height) {
				resizeFactor = nativeWindows[1].height/video.height;
			}
			trace("Video Width: " + video.width);
			trace("Video Height: " + video.height);
			trace("Resize Factor: " + resizeFactor);
			
			video.width = video.width * resizeFactor;
			video.height = video.height * resizeFactor;
			
			trace("x math: " + (nativeWindows[1].width - video.width)/2);
			trace("y math: " + (nativeWindows[1].height - video.height)/2);
			video.x = (nativeWindows[1].width - video.width)/2;
			video.y = (nativeWindows[1].height - video.height)/2;
			*/
			
			var key:String;
			for(key in infoObject){
				log(key+": "+infoObject[key]);
			}			
		}
		
		private function onPlayStatus(infoObject:Object):void {
			log("onPlayStatus");
			var key:String;
			for(key in infoObject){
				log(key+": "+infoObject[key]);
			}
		}		
		
		private function securityErrorHandler(event:SecurityErrorEvent):void {
			log("securityErrorHandler: " + event);
		}
		
		private function ncStatus(event:NetStatusEvent):void 
		{
			log(event.info.code);
			
			switch (event.info.code) 
			{		
				case "NetConnection.Connect.Success":
					
					var inStream:NetStream = new NetStream(nc);
					inStream.addEventListener(NetStatusEvent.NET_STATUS, ncStatus);
					
					var dumbObject:Object = new Object();
					dumbObject.onCuePoint = cuePoint; 
					dumbObject.onMetaData = metaData;
					inStream.client = this;
					
					inStream.play(stream);
					
					remoteVideo = new Video();
					remoteVideo.attachNetStream(inStream);
					
					setDimensions(480, 270);
										
					addChild(remoteVideo);
					
					break;
				
				case "NetStream.Play.StreamNotFound":
				
					break;
				
				default:

					break;
			}
		}
		
		private function setDimensions(_width:Number, _height:Number):void {
			
			if (remoteVideo != null) {
				remoteVideo.width = _width;
				remoteVideo.height = _height;
			
				//this.width = _width;
				//this.height = _height;
			}
			
		}
	}
}