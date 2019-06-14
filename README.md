<h1>Pure B</h1>

<h3>Current Version: 1.4.0 beta</h3>

<div id="contents">
	<h2>Contents:</h2>
	<ol>
		<li><a href="#intro">Intro</a></li>
		<li><a href="#howTo">How to use</a></li>
		<li><a href="#mainVariables">Pure Variables</a></li>
		<li><a href="#mainFunctions">Pure Functions</a></li>
		<li><a href="#packages">Packages</a></li>
		<li><a href="#modules">Modules</a></li>
		<li><a href="#tools">Tools</a></li>
		<li><a href="#reservedArgs">Reserved Arguments</a></li>
		<li><a href="#pakModRules">Package and Module definition</a></li>
		<li><a href="#customPackages">Custom Packages and Modules</a></li>
		<li><a href="#moduleCache">Module Cache</a></li>
		<li><a href="#moduleAlias">Module Aliases</a></li>
		<li><a href="#pureAsArgsParser">Using Pure as a long argument parser</a></li>
		<li><a href="#references">References</a></li>
		<li><a href="#about">About</a></li>
	</ol>
</div>

<div id="intro">
	<h2>Intro:</h2>
	<p>
	Pure Bash Library/Mini Framework, entirely based on bash built-in commands, no other core utils, busybox or external binaries where used, only bash 4+ is required.
	</p>
	<p>
	The goal of Pure is to provide an easy way to source a bunch of scripts without the need to know its exact location just like a common programming language such as Java <code>import package</code> or C <code>#include header</code>, the Pure equivalent would be <code>require package/module</code>.
	</p>
	<p>
	Pure is already shipped with two <a href="#packages">packages</a> and a bunch of <a href="#modules">modules</a>, but you can define <a href="#pakModRules">your own packages and modules</a> 
	</p>
</div>

<div id="howTo">
	<h2>How to use:</h2>
	<ol>
		<li>Clone git: <code>cd ~ && git clone https://github.com/BasherSG/Pure-B .pure</code></li>
		<li>Loading Pure: <code>
		source &#126;&#47;.pure&#47;pure.sh</code> on your script or at the terminal.
		</li>
		<li>Using modules: <code>require core/mssg</code> or like an argument <code>./myscript.sh --mssg</code> (load from package &#706;core&#707; module &#706;mssg&#707;)</li>
		<li>Using an entire package: <code>require proto</code> (load package &#706;proto&#707;)</li>
		<li>Using a function from a module: <code>require core/util ; fake_sleep 10s</code> (Call &#706;fake_sleep&#707; from &#706;util&#707; module)</li>
	</ol>
</div>

<div id="mainVariables">
	<h2>Pure Variables:</h2>
	<p>Pure defines a few useful variables when it starts:</p>
	<ul>
		<li>SELF: The name of the current script.</li>
		<li>SELF_PURE: Pure main script location.</li>
		<li>SELF_HEADER: Pure header script location.</li>
		<li>SELFNAME: The name of the current script without extension.</li>
		<li>CWD (Current Working Directory): Path to the script.</li>
		<li>LWD (Library Working directory): Path to pure.</li>
		<li>PURE_VERSION: Current pure version.</li>
		<li>PURE_VERSINFO: Easily parseable versión info.</li>
		<li>ARGS: Clean script arguments, this variable is set to access the arguments of your script without all the pure related arguments so <code>./myscript.sh -a blah --pak=proto --sigcomm --pak=core --dir -b</code> would produce <code>ARGS=([1]='-a' [2]='blah' [3]='-b')</code>.</li>
		<li>DEF_PACK: Default package for module arguments, mainly does nothing but for <a href="#pureAsArgsParser">this</a> purpose.</li>
	</ul>
</div>

<div id="mainFunctions">
	<h2>Pure Functions:</h2>
	<ul>
		<li id="require"><h4>require:</h4>
			<p>Syntax: <code>require &#706;package_name&#124;package_name&#47;module_name&#707;</code><p>
			<p>
			It's the way to use a module from a package or an entire package if no module is provided. <b>Modules are obtained only once.</b>
			</p>
			<p>
			Example: <code>require core/dir</code> Use module &#706;dir&#707; from &#706;core&#707;
			</p>
			<p>
			Example: <code>require core</code> Use all &#706;core&#707; modules
			</p>
		</li>
		<li id="depend"><h4>depend:</h4>
			<p>Syntax: <code>depend &#706;command&#707;</code></p>
			<p>
			A more reliable way to depend on non builtin commands than just doing <code>command -v &#706;command&#707; || exit 1</code>, depend does that and un-sets any function that has been named like such &#706;command&#707;.
			</p>
			<p>
			Even though depending on external binaries is not a good idea when making standalone scripts, at least by using depend you can rest assure that the command that you need is present on the system, but is up to you to handle version changes or OS differences.
			</p>
			<p>
			Example: <code>depend cat</code> Depend on command cat
			</p>
		</li>
		<li id="map_packages"><h4>map_packages:</h4>
			<p>Syntax: <code>map_packages</code></p>
			<p>As the name implies, new packages can be created even after the script has already launched, by running this function new packages will be mapped.</p>
		</li>
		<li id="map_modules"><h4>map_modules:</h4>
			<p>Syntax: <code>map_modules</code></p>
			<p>Also new modules can be mapped while the script is running.</p>
		</li>
		<li id="loaded_modules"><h4>loaded_modules:</h4>
			<p>Syntax: <code>loaded_modules</code></p>
			<p>A human readable way to know which packages and modules is a script using.</p>
		</li>
	</ul>
</div>

<div id="packages">
	<h2>Packages:</h2>
	<p>Pure main functionalities are shipped into packages, the main goal of a package is to group multiple <a href="#modules">modules</a> into a common namespace.</p>
	<ul>
		<li>core: Main package, stable and core modules</li>
		<li>proto: Unstable experimental modules</li>
		<li>my_pack: Example package</li>
	</ul>
</div>

<div id="modules">
	<h2>Modules:</h2>
	<p>Modules are scripts that can be sourced, each module groups functions or runs some kind of code when called. Modules can also serve as <a href="#pureAsArgsParser">long arguments for scripts</a>.</p>
	<ul>
		<li><h3>core modules:</h3><ul>
			<li>base64(Stable): Base 64 string encoding and decoding functions</li>
			<li>color(Stable): String coloring functions</li>
			<li>conf(Stable): Simple config file management</li>
			<li>ctrl(Stable): Script external interruptions management, also like a way to tell scripts what to do.</li>
			<li>daemon(Unstable): Process locking and daemonization</li>
			<li>dir(Stable): File and folder test, list, and search functions</li>
			<li>log(Stable): Transparent logging file management (printf output not loggable)</li>
			<li>mssg(Stable): Easy colored message functions</li>
			<li>opp(Stable): Mathematical and numerical testing functions</li>
			<li>opts(Stable): Easy option parsing</li>
			<li>proc(Stable): Process test, list, search functions</li>
			<li>trace(Stable): Tracing of function calls and last function called</li>
			<li>tty(Stable): Active ttys and current tty begin used functions</li>
			<li>util(Stable): Common use functions</li>
		</ul></li>
		<li><h3>proto modules:</h3><ul>
			<li>aes(Untested): Pure Bash implementation of ECB Aes algorithm</li>
			<li>brnfck(Brocken): Brain fu*k interpreter (No clue how to deal with nested loops)</li>
			<li>cursor(Brocken): Mouse cursor recognition</li>
			<li>sigcomm(Unstable): Communication system based on kill signals (Only works with delays)</li>
			<li>types(Unstable): Nestable type definitions in a few pure bash lines</li>
		</ul></li>
		<li><h3>my_pack modules:</h3><ul>
			<li>hello: Simple example module</li>
		</ul></li>
	</ul>
</div>

<div id="tools">
	<h2>Tools:</h2>
	<p>Pure has some additional tools intended to pack, debug or to read Pure documentation</p>
	<ul>
		<li>debugger(Brocken):  Debugger intended to be like gdb with it's basic functionalities</li>
		<li>manual(In-Progress): Interactive manual.</li>
		<li>shcpacker(Working-Beta): Intended to be used with shc (Shell script compiler), by packing all the used modules and their requirements into a single script</li>
	</ul>
</div>

<div id="reservedArgs">
	<h2>Reserved Arguments:</h2>
	<p>
	Pure has some reserved arguments:
	</p>
	<ul>
		<li>--debug: Enable bash debugging functionality</li>
		<li>--cache: Enable local <a href="#moduleCache">cache</a></li>
		<li>--reload: Reload cache</li>
		<li>--pak=&#706;package_name&#707;: Package to use on the subsequent module arguments</li>
		<li>--&#706;module_name&#707;: Module argument to load before script</li>
		<li>--mdl_alias: Enable module aliases</li>
	</ul>
<div>

<div id="pakModRules">
	<h2>Package and Module definition:</h2>
	<p>
		There are some rules to have in mind before defining your own modules and packages:
	</p>
	<ol>
		<li>Package and module names should only contain lowercase characters &#706;a-z&#707; and&#47;or underscore &#706;_&#707;</li>
		<li>Every module must be in a package</li>
		<li>Automatic package nesting is currently not supported</li>
		<li>Modules should have the &#706;.sh&#707; file extension</li>
		<li>Very long module names may be aliased using the <a href="#moduleAlias">module alias</a> feature</li>
		<li>A local <a href="#moduleCache">cache</a> should be used when defining custom modules and packages</li>
		<li>The path to de custom package folder should not contain any &#706;:&#707; colon character, since it's used to define multiple paths</li>
		<li>
		By defining your custom package into the path where pure.sh is located it will be mapped automatically by the --reload argument and will be able to be used as a global package without the need to predefine the <code>PACK_FOLD</code> variable
		</li>
	</ol>
</div>

<div id="customPackages">
	<h2>Custom Packages and Modules:</h2>
	<p>
	To define custom packages and modules you must follow the <a href="#pakModRules">rules</a> stated above, then you should define the variable <code>declare -x PACK_FOLD=&#34;&#47;path&#47;to&#47;custom&#47;package&#47&#34; </code> <b>before sourcing pure</b>.
	</p>
	<p>
	If you want to define multiple packages you can delimit their paths with a &#706;:&#707; colon character <code>declare -x PACK_FOLD=&#34;&#47;path&#47;to&#47;custom&#47;package_one&#47;&#58;&#47;path&#47;to&#47;custom&#47;package_two&#47;&#34; </code>
	</p>
</div>

<div id="moduleCache">
	<h2>Module Cache:</h2>
	<p>
	Intended to enhance CPU consumption on subsequent executions, cache can be stored globally or locally, local cache meant to be used when custom packages are defined outside of the &#706;pure.sh&#707; folder otherwise the global cache is recommended. 
	</p>
	<p>
	To set a local cache with a custom name just define the variable <code> declare -x CACHE_FILE=".mycache.cache"</code> <b>before sourcing pure</b>.
	</p>
</div>

<div id="moduleAlias">
	<h2>Module Aliases:</h2>
	<p>
	Module aliases are meant to shorten the names of the modules or to provide an alternative way to call a module.
	</p>
	<p>
	To define a module alias you should add the line <code>#MODULE: &#706;module_alias&#707;</code> ideally just a after the shebang but before the <b>sixth line</b> of your module.
	</p>
	<p>
	To enable module alias just provide the argument --mdl_alias or define the variable <code>declare -x MDL_ALIASES=true</code> <b>before sourcing pure</b>.
	</p>
</div>

<div id="pureAsArgsParser">
	<h2>Using Pure as a long argument parser</h2>
	<p>Steps:</p>
	<ol>
		<li>(Only needed if your package is located outside of &#706;pure.sh&#707; folder) Define the path to your <a href="#customPackages">custom package</a> and use <a href="#moduleCache">module cache</a>.</li>
		<li>Define <code>declare -xg DEF_PACK='package'</code> to the name of custom package</li>
		<li><a href="#howTo">Source pure</a>.</li>
		<li>Now call your script like this <code>./myscript.sh --long_arg</code> &#706;long_arg&#707; must be the name of a module inside your custom package.</li>
	</ol>
	<p>Example:</p>
	<code>~$ cat << EOF > myscript.sh</code><br>
	<code>#!/bin/bash</code><br>
	<code>declare -xg DEF_PACK="my_pack"</code><br>
	<code>source &#126;&#47;.pure&#47;pure.sh</code><br>
	<code>EOF</code><br>
	<code>~$ chmod +x myscript.sh</code><br>
	<code>~$ ./myscript.sh --hello</code><br>
	<code>hello world</code>
</div>

<div id="references">
	<h2>References:</h2>
	<ul>
		<li>The Pure Bash Bible by Dylan Araps: <a href="https://github.com/dylanaraps/pure-bash-bible">https://github.com/dylanaraps/pure-bash-bible</a></li>
		<li>AES algorithm implementation in C by Dhuertas: <a href="https://github.com/dhuertas/AES">https://github.com/dhuertas/AES</a></li>
	</ul>	
</div>

<div id="about">
	<h2>About:</h2>
	<h3>Notice:</h3>
	<p>I am by no means an expert into this library/framework matter if you think that it's not quite accurate to call this project a library/framework then point me out to the right term and i'll fix it as soon as i can or to any other kind of enhancement that must be done.</p>
	<h3>Support Pure:</h3>
	<p>If your are willing to support Pure by developing your own packages and modules, i'll be most pleased to share the link here if you upload it to a new repo.</p>
	<h3>About Pure:</h3>
	<p>Pure was developed as a hobby project entirely as a way to make standalone scripts with ease, and to collect all that i have learnt so far from bash.</p>
	<p>Theoretically since Pure's only dependence is bash 4+ it could run on cygwin(Windows) and termux(Android) with minimal or no effort, but i have not tested this yet, if you are in need or willing to test it, please share your test results.</p>
	<h3>About Me:</h3>
	<p>I am a passionate developer always looking to best my skills, always trying to learn from facts and failures, i love to develop useful (at least for me) bash scripts and learn hackish ways of programming things.</p>
</div>
