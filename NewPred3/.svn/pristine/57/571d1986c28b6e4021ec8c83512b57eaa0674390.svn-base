/**
 * Jalview - A Sequence Alignment Editor and Viewer (Version 2.8)
 * Copyright (C) 2012 J Procter, AM Waterhouse, LM Lui, J Engelhardt, G Barton, M Clamp, S Searle
 * 
 * This file is part of Jalview.
 * 
 * Jalview is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License 
 * as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *  
 * Jalview is distributed in the hope that it will be useful, but 
 * WITHOUT ANY WARRANTY; without even the implied warranty 
 * of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
 * PURPOSE.  See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with Jalview.  If not, see <http://www.gnu.org/licenses/>.
 */
// default console to report messages
var _console = document.getElementById("stdout");
var _jvapps = new Array();
// jvjmols is a list associating a jmol id to { modelstofiles }
var _jvjmols = new Hashtable();
// array of model names used to lookup index in Jmol
var _modeltofiles = new Array();
// counter for jmol structures
var mnum = 1;

function setConsole(console) {
	_console = console;
}

function getDestinationFrms(source, frames) {
	var frms = new Array();
	var frid = "";
	for (frm in frames) {
		try {
			frid = (source!=null) && (("" + source.getSequenceSetId()) == ("" + frames[frm].currentAlignFrame
					.getSequenceSetId()));
		} catch (q) {
		};
		
		if (!frames[frm].equals(source) && !frid
				&& !frames[frm].currentAlignFrame.equals(source)) {
			frms[frms.length] = frames[frm];
		}
	}
	return frms;
}

function mouseover(list1, list2, list3, list4) {
	// list1 = new Object(list1);
	var list = new Array(("" + list1), ("" + list2), ("" + list3), ("" + list4));
	var msg = "Mouse over :\n" + "AlignFrame obj: " + list1 + " Seq : "
			+ list[1] + "\nPos: " + list[2] + "(" + list[3] + ")\n";

	var flist = getDestinationFrms(list1, _jvapps);
	if (_console) {
		_console.value = msg + "\n";
	}

	for (follower in flist) {
		if (_console) {
			_console.value += "Sending to " + flist[follower] + "\n";
		}
		flist[follower].highlight(list[1], list[2], "true");
	}
	return true;
}

function sellist(list1, list2, list3, list4) {
	// list1 = new Object(list1);
	var list = new Array(("" + list1), ("" + list2), ("" + list3), ("" + list4));
	var msg = "Selection:\n" + "AlignFrame obj: " + list[0] + " id : "
			+ list[1] + "\nSeqs " + list[2] + "\nColumns " + list[3] + "\n";
	var flist = getDestinationFrms(list1, _jvapps);
	if (_console) {
		_console.value = msg + "\n";
	}
	
	for (follower in flist) {
		if (_console) {
			_console.value += "Sending to " + flist[follower] + "\n";
		}
		flist[follower].selectIn(flist[follower].getDefaultTargetFrame(),
				list[2], list[3])
	}
	return true;
}

function viewlist(list1, list2, list3, list4) {
	// list1 = new Object(list1);
	var list = new Array(("" + list1), ("" + list2), ("" + list3), ("" + list4));
	var msg = "Viewport extent change::\n" + "AlignFrame obj: " + list[0]
			+ " id : " + list[1] + "\nRow from " + list[2] + " and to "
			+ list[3] + "\nVisible columns: " + list[4] + "\n";
	var flist = getDestinationFrms(list1, _jvapps);
	if (_console) {
		_console.value = msg + "\n";
	}

	for (follower in flist) {
		if (_console) {
			_console.value += "Sending to " + flist[follower] + "\n";
		}
		flist[follower].scrollToViewIn(flist[follower].getDefaultTargetFrame(),
				list[2], "-1");
	}
	return true;
}

// register a jalview applet and add some handlers to it
// jmolView is a reference to a jmol applet that is displaying the PDB files listed (in order) in the modeltofiles Array
function linkJvJmol(applet, jmolView, modeltofiles) {
	var i = _jvapps.length;
	while (i--) {
		if (_jvapps[i].equals(applet)) {
			throw ("Ignoring additional linkJvJmol call for "
					+ applet.getName() + ".");
		}
	}
	_jvapps[_jvapps.length] = applet;
	applet.setMouseoverListener("mouseover");
	applet.setSelectionListener("sellist");
	// viewListener not fully implemented in 2.7
	// try { applet.setViewListener("viewlist"); } catch (err) {};
	if (jmolView)
	{
		var sep = applet.getSeparator();
		var oldjm=jmolView;
		// recover full id of Jmol applet
		jmolView=_jmolGetApplet(jmolView).id;
		var jmbinding=_jvjmols.get(jmolView);
		if (!jmbinding)
		{	
			jmbinding=new Object();
			jmbinding._modelstofiles=new Array();
			jmbinding._fullmpath=new Array();
			jmbinding._filetonum=new Hashtable();
			jmbinding._jmol=jmolView;
			jmbinding._jmhandle=oldjm;
			_jvjmols.put(jmolView,jmbinding);
		}
		
		jmbinding._modelstofiles=jmbinding._modelstofiles.concat(jmbinding._modelstofiles,modeltofiles);
		jmbinding._jmol=jmolView;
		// now update structureListener list
		mtf="";
		var dbase = document.baseURI.substring(0,document.baseURI.lastIndexOf("/")+1);
		for (m in jmbinding._modelstofiles)
		{ if (m>0) { mtf+=sep; }
		mtf+=jmbinding._modelstofiles[m];
		if (jmbinding._modelstofiles[m].indexOf("//")==-1)
			{ jmbinding._fullmpath[m] = dbase+((jmbinding._modelstofiles[m].indexOf("/")==0) ? jmbinding._modelstofiles[m].substring(1) : jmbinding._modelstofiles[m]); }
		  jmbinding._filetonum.put(jmbinding._modelstofiles[m], m+1); 
		  jmbinding._filetonum.put(jmbinding._fullmpath[m], m+1);
		  
		  }
		applet.setStructureListener("_structure", mtf);
	}
}

/*function _addJmolModel(jmolid, modelname) {
	modelname=""+modelname;
	var jminf = _jvjmols[jmolid];
	if (!jminf) {
		jminf = new Object();
		jminf._modelstofiles = new Array(); //new Hashtable();
		jminf._jmol = jmolid;
		jminf._modellist=new Array();
		_jvjmols[jmolid] = jminf;
	}
	var obj = new Object();
	jminf._modeltofiles[modelname] = obj; // .put(modelname, obj);
	obj.id = modelname;
	obj.mnum = jminf._modeltofiles.length;
	jminf._modellist+=modelname;
}*/



// jmol Jalview Methods

function _structure(list1, list2, list3, list4) {
	var follower;
	// if (_console) { if (!_console.value) { _console.value="";} }
	if (list1 == "mouseover") {
		var list = new Array(("" + list1), ("" + list2), ("" + list3),
				("" + list4));
		// 1 is pdb file, 2 is residue number, 3 is chain
		// list1 = new Object(list1);
		var base = list[1].indexOf(document.baseURI
				.substring(0, document.baseURI.lastIndexOf('/'))
				); // .indexOf(_path);
		if (base==0) { base = document.baseURI.lastIndexOf('/'); }
		var sid = list[1]; // .substring(base);
		base = list[1].substring(0, base);
		if (_console) {
			_console.value += "Model is " + list[1] + ", Structure id is : "
					+ sid + "\n";
		}
		;
		var siddat;
		for ( var jmolappi in _jvjmols.values()) {
			var jmolapp=_jvjmols.values()[jmolappi];
			var msg = "";
			if (siddat = jmolapp._filetonum.get(sid)) {
				// we don't putin chain number because there isn't one ?
				// skip select 0 bit
				var ch = ""+list[3];
				if ((""+list[2]).trim().length==1)
					{
					ch+=":"+list[2];
					}
				msg = "select (" + ch + " /" + siddat + ") ;";
			}
			if (msg) {
				if (_console) {
					_console.value += "Sending '" + msg + "' to jmol." + "\n";
				}
			}
			jmolScriptWait(msg, "" + jmolapp._jmhandle);
			// only do highlight for one jmol ?
			// return 1;
		}
	}
	if (list1 == "colourstruct") {
		if (_console) {
			_console.value += 'colourStruct("' + list1 + '","' + list2
			+ '") [' + list4 + ']' + "\n";
		}
		setTimeout('colourStruct("'+list4+'","' + list1 + '","' + list2 + '")', 1);
		return 1;
	}
	return 1;
}
// last colour message
var _lastMsg = "";
// indicator - if _colourStruct==0 then no colouring is going on
var _colourStruct = 0;

function colourStruct(involves, msg, handle) {
	if (_colourStruct == 0) {
		_colourStruct = 1;
		for (ap in _jvapps) {
			var _msg = "";
			do {
				if (_msg.match(/\S/)) {
					_lastMsg += _msg;
				}
				_msg = "" + _jvapps[ap].getJsMessage(msg, handle);
			} while (_msg.match(/\S/));
		}
		// locate the jmol that should get the message
		for (var jmol in _jvjmols.values())
			{
			var jml=_jvjmols.values()[jmol];
			if (jml._filetonum.get(involves))
				{
					colourStructs(jml._jmhandle);
				}
			}
		_colourStruct = 0;
	} else {
		// setTimeout('colourStruct("'+msg+'","'+handle+'")',3);
	}
}

function colourStructs(jmolapp) {
	dbg(0, "Colouring the structures\n");
	jmolScriptWait("set selectionhalos false;" + _lastMsg
			+ "; select 0; set selectionhalos true;", jmolapp);
	_lastMsg = "";
}
var _jmolhovermsg="";
function _jmolhover(jmid, atomlabel, atomidx) {
	var msg=""+jmid+" "+atomlabel+" "+atomidx;
	if (_jmolhovermsg==msg)
		{
		return;
		}
	_jmolhovermsg=msg;
	modeltofiles = _jvjmols.get(jmid)._modelstofiles;
	// atomlabel=(""+atomlabel).match(/\[(.+)\](\d+):(.)\.(\S+)\s*\/(\d+)\..+/);
	// relaxed third parameter - may be null or a model number for multi model
	// views
	atomlabel = ("" + atomlabel)
			.match(/\[(.+)\](\d+):(.)\.([^\/]+)(\/\d+\.|).+/);
	atomidx = "" + atomidx;
	if (atomlabel[5]) {
		atomlabel[5] = atomlabel[5].match(/\/(.+)\./)[1];
		atomlabel[5] = parseInt(atomlabel[5])-1;
	} else {
		// default - first model
		atomlabel[5] = 0;
	}
	// use atomlabel[5] to look up model filename so we can highlight associated positions in any jalviews
	for (ap in _jvapps) {
		_jvapps[ap].mouseOverStructure(atomlabel[2], atomlabel[3],
				document.baseURI
						.substring(0, document.baseURI.lastIndexOf('/'))
						+ "/" + 
						modeltofiles[atomlabel[5]]);
		msg = _jmolhovermsg;
	}
}
function _jmolpick(jmid, atomlabel, atomidx) {
	atomlabel = "" + atomlabel;
	atomidx = "" + atomidx;
	// label is atom id, atom number, and xyz coordinates in the form:
	// C6 #6 -0.30683374 -1.6836332 -0.716934
	// atom index, starting with 0.

}
function _jmolMessagecallback(jmid, statmess) {
	// if (statmess.indexOf("Script Terminated")==0)
	{
		var thisTime = new Date();
		if (_console) {
			_console.value += "Last script execution took : "
					+ (thisTime.valueOf() - _lastTime.valueOf()) / 1000.0
					+ " seconds.";
		}
		_lastTime = thisTime;

	}
}
