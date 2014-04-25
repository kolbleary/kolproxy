register_setting {
	name = "use iframes instead of frames",
	description = "use iframes instead of frames",
	group = "other",
	default_level = "enthusiast",
	update_charpane = true,
	beta_version = true,
}

add_interceptor("/game.php", function()
	if not setting_enabled("use iframes instead of frames") then return end
return [[
<!DOCTYPE html>
<html><head><title>The Kingdom of Loathing</title><script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-47556088-1', 'kingdomofloathing.com');
  ga('send', 'pageview');

</script><script type="text/javascript" src="http://code.jquery.com/jquery-1.11.0.min.js"></script>
<script type="text/javascript" src="http://code.jquery.com/ui/1.10.4/jquery-ui.min.js"></script>
<link rel="stylesheet" href="//code.jquery.com/ui/1.10.4/themes/overcast/jquery-ui.css">
<style type="text/css">

  body {
   margin: 0px;
   padding: 0px;
}

  #wrapper {
  min-height: 800px;
  margin: 0px 0px 0px 0px;
  padding: 0px 0px 0px 0px;
  display: -webkit-flex;
  display: flex;
  -webkit-flex-flow: row;
  flex-flow: row;
  }


  #menupane {
  background-color: #eee;
  min-height: 50px;
  height: 50px;
  width: 100%;
  display: block;
  }

  #charpane {
  -webkit-flex: 1;
  flex: 1;
  max-width: 200px;
  -webkit-order: 1;
   order: 1;
  }

  #mainpane {
-webkit-flex: 3;
flex: 3;
order: 2;
  }

  #chatpane {
  -webkit-flex: 1;
  flex: 1;
  order: 3;
  -webkit-order: 3;
  }

  #popup
{ display: none;
opacity: 0.9;

}

#hidden {width: 100%;
height: 95%;  };

.ui_dialog { opacity: 0.9;}
.ui-dialog .ui-dialog-titlebar
{padding: 0;}
 .ui-widget-content {
    background: #C9C9C9;
} </style>
</head>

<body>

      <iframe src="topmenu.php" scrolling="no" id="menupane" name="menupane">
        topmenu
      </iframe>
  <div id="wrapper">
<iframe src="charpane.php" id="charpane" name="charpane">
        charpane
      </iframe>
      <iframe src="main.php" name="mainpane" id="mainpane">
        mainpane
      </iframe>
    <iframe src="chatlaunch.php" id="chatpane" name="chatpane">
      chatpane
    </iframe>
  </div> <!-- end wrapper -->
<div id="popup"><iframe id="hidden"></iframe></div>

</body>
</html>
]]


end)
