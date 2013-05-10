package
{
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.system.Security;

	[SWF(width='480',height='270',backgroundColor='#000000',frameRate='25')]
	
	public class SimpleStreamingVideoPlayer extends Sprite
	{
		private var nc:NetConnection;
		private var server:String;
		private var stream:String;
		
		private var remoteVideo:Video;
		
		public var videoWidth = 480;
		public var videoHeight = 270;
		
		public function SimpleStreamingVideoPlayer()
		{
			Security.allowDomain("*");
			
			if (ExternalInterface.available) 
			{	
				log("ExternalInterface.avaialble");
				
				ExternalInterface.addCallback("startStream", startStream);
				ExternalInterface.addCallback("disconnectStream", disconnectStream);
				ExternalInterface.addCallback("log", log);
				
				ExternalInterface.call("playerInit",ExternalInterface.objectID);
			}
									
			remoteVideo = new Video();										
			addChild(remoteVideo);
			
			var transparentSprite:Sprite = new Sprite();
			transparentSprite.graphics.beginFill(0x00ff00, 0);
			transparentSprite.graphics.drawRect(0, 0, videoWidth, videoHeight);
			transparentSprite.graphics.endFill();
			addChild(transparentSprite);
			
			addEventListener(MouseEvent.CLICK, playerClicked);
						
			setDimensions(videoWidth, videoHeight);
		}
		
		private function log(message:String) {
			trace(message);
			if (ExternalInterface.available) {
				ExternalInterface.call("console.log", message);
			}
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
		
		private function sdes(infoObject:Object): void {
			log("sdes");
		}
		
		private function metaData(infoObject:Object):void {
			log("metaData");
			
			if (infoObject.width != null && infoObject.hight != null) {
				setDimensions(infoObject.width, infoObject.height);
			}
			
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
					dumbObject.onSDES = sdes;
					inStream.client = dumbObject;
					
					inStream.play(stream);
					
					remoteVideo.attachNetStream(inStream);
					
					break;
				
				case "NetStream.Play.StreamNotFound":
					
					break;
				
				default:
					
					break;
			}
		}
		
		public function playerClicked(event:MouseEvent):void 
		{
			log("playerClicked");
			if (ExternalInterface.available) {
				ExternalInterface.call("playerClicked", ExternalInterface.objectID);
			}
		}
		
		private function setDimensions(_width:Number, _height:Number):void 
		{
			log("setDimensions: " + _width + " " + _height);	
			
			this.width = _width;
			this.height = _height;
			
			if (remoteVideo != null) {
				log("setDimensions: " + _width + " " + _height);	
				
				remoteVideo.width = _width;
				remoteVideo.height = _height;
			}
		}
	}
}