/****************************************************************************

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

See <http://www.gnu.org/licenses/>.

-- iPhone Page Scroll in AS3
-- Copyright 2010 Naftali Andrade Santos
-- naftali.a.santos@gmail.com
-- http://dev.naftali.com.br

****************************************************************************/

package br.com.naftali.components
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/**
	 * Class created to resemble the effect of changing a page like
	 * the main page on the iPhone.
	 * 
	 * Feel free to read it through, help and improve this class.
	 * 
	 * The pages are known by each movieclip inside the pContent MovieClip.
	 * 
	 * @author 	Naftali Andrade Santos
	 * @website http://naftali.com.br
	 */
	public class IPhonePageScroller extends EventDispatcher
	{
		private var _content:MovieClip;
		private var _stage:Stage;
		
		private var _arPages:Array;
		private var _mouseDown:Boolean;
		private var _mouseDownTime:uint;
		private var _mouseDiff:Number;
		
		private var _currentPage:MovieClip;
		private var _nearestPage:MovieClip;
		
		// helpers
		private var _point:Point; // created to avoid constructing lots os points inside the code, therefore geting some processing time for us.
		private var _startMouseX:Number;
		private var _speed:Number;
		
		// Properties
		private var _pageWidth:Number;
		private var _pagePosition:Number;
		private var _sensitiveness:Number;
		private var _moving:Boolean;
		
		//constants
		private static const MIN_DISTANCE:Number 			= 1;
		private static const SMOOTHNESS:Number 				= 0.5;
		private static const TIME_MODIFIER:Number			= 100;
		private static const SPEED_MULTIPLIER:Number		= 50;
		
		public static const DEFAULT_SENSITIVENESS:Number 	= 10;
		
		/**
		 * Constructor
		 * @param	pContent 	The movieclip that holds the pages
		 * @param	pStage		Stage, so that some listeners can be added
		 */
		public function IPhonePageScroller( pContent:MovieClip, pStage:Stage ):void
		{
			_content 		= pContent;
			_stage			= pStage;
			_mouseDownTime 	= 0;
			_arPages		= new Array();
			_point			= new Point();
			_pagePosition	= 0;
			_currentPage	= null;
			_nearestPage	= null;
			_sensitiveness	= DEFAULT_SENSITIVENESS;
			
			indexPages();
			
			_content.addEventListener( MouseEvent.MOUSE_DOWN, onContentMouseDown );
			_stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
		}
		
		/**
		 * The method to be called every frame. Instead of reading the enter frame event directly,
		 * I prefer to have this method in every class I create and make it be called in one ENTER_FRAME.
		 * This makes it easier to pause, an element, for example
		 * 
		 * @param	p_transport Object that holds the time passed between this and the last ENTER_FRAME. May or may not hold the fps, depending on the project.
		 */
		public function process( p_transport:Object ):void
		{
			if ( _mouseDown )
				followMouse( p_transport );
			else
				fixToNearest( p_transport );
		}
		
		private function fixToNearest( p_transport:Object ):void
		{
			if ( _nearestPage )
			{
				_point.x = _nearestPage.x;
				_point.y = _nearestPage.y;
				
				var global:Point = _nearestPage.parent.localToGlobal( _point );
				global = _content.parent.globalToLocal( global );
				
				var dist:Number	= _pagePosition - global.x;
				var distToRun:Number = dist * ( SMOOTHNESS * ( p_transport.time / TIME_MODIFIER ) );
				_content.x += distToRun;
				
				var distance:Number = Math.abs( _pagePosition - ( global.x + distToRun ) );
				
				if ( distance < MIN_DISTANCE )
					arrived();
			}
		}
		
		private function arrived():void
		{
			_moving = false;
			_content.x = _pagePosition - _nearestPage.x;
			
			_currentPage = _nearestPage;
			_nearestPage = null;
			
			dispatchEvent( new IPhonePageScrollerEvents( IPhonePageScrollerEvents.PAGE_FOCUS_END, _currentPage ) );
		}
		
		private function findNearestPage():void
		{
			var selected:MovieClip 	= null
			var selectedDist:int 	= int.MAX_VALUE;
			
			for each( var mc:MovieClip in _arPages )
			{
				_point.x = mc.x + _speed;
				_point.y = mc.y;
				
				var global:Point 	= mc.parent.localToGlobal( _point );
				var dist:Number 	= Math.abs( global.x - _pagePosition );
				
				if ( dist < selectedDist )
				{
					selected 		= mc;
					selectedDist 	= dist;
				}
			}
			
			_nearestPage = selected;
			
			dispatchEvent( new IPhonePageScrollerEvents( IPhonePageScrollerEvents.PAGE_FOCUS_START, _nearestPage ) );
		}
		
		private function followMouse( p_transport:Object ):void
		{
			if ( ( _mouseDownTime > 0 ) || Math.abs( _stage.mouseX - _startMouseX ) > _sensitiveness )
			{
				// can be used to calculate the speed
				_mouseDownTime += p_transport.time;
				
				_point.x = _stage.mouseX;
				_point.y = _stage.mouseY;
				
				var local:Point = _content.parent.globalToLocal( _point );
				_content.x = local.x - _mouseDiff;
				
				if ( !_moving )
					_moving = true;
			}
		}
		
		/**
		 * A method to remove the listeners, the objects and everything else, 
		 * so it can be easily thrown away by the garbage collector.
		 */
		public function release():void
		{
			_content.removeEventListener( MouseEvent.MOUSE_DOWN, onContentMouseDown );
			_stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			
			_content 	= null;
			_stage		= null;
		}
		
		private function indexPages():void
		{
			for ( var i:int = 0; i < _content.numChildren; ++i )
			{
				var mc:MovieClip = _content.getChildAt( i ) as MovieClip;
				
				if ( mc )
				{
					_arPages.push( mc );
					pageWidth = mc.width;
				}
			}
			
			_arPages.sortOn( "x", Array.NUMERIC );
		}
		
		private function onContentMouseDown(e:MouseEvent):void 
		{
			startMouseDown();
		}
		
		private function onStageMouseUp(e:MouseEvent):void 
		{
			endMouseDown();
		}
		
		private function startMouseDown():void
		{
			if ( !_mouseDown )
			{
				_mouseDown 		= true;
				_mouseDownTime 	= 0;
				
				_point.x = _content.x;
				_point.y = _content.y;
				
				var global:Point = _content.parent.localToGlobal( _point );
				
				_mouseDiff		= _stage.mouseX - global.x;
				_startMouseX	= _stage.mouseX;
			}
		}
		
		private function endMouseDown():void
		{
			if ( _mouseDown )
			{
				_mouseDown = false;
				
				var dist:Number 	= _stage.mouseX - _startMouseX;
				_speed 	= 0;
				
				if ( _mouseDownTime != 0 )
					_speed = ( dist / _mouseDownTime ) * SPEED_MULTIPLIER;
				
				//trace( "dist: " + dist + " | mousedowntime: " + _mouseDownTime + " | speed: " + speed );
				
				findNearestPage();
			}
		}
		
		/**
		 * Force one page to be focused, wherever it is.
		 * @param	pPage Page to focus
		 */
		public function forceFocusOnPage( pPage:MovieClip ):void
		{
			var found:Boolean = false;
			
			// first we need to know if this page exists in our index
			for each( var mc:MovieClip in _arPages )
			{
				if ( mc == pPage )
				{
					found = true;
					break;
				}
			}
			
			if ( found )
			{
				_nearestPage = pPage;
				dispatchEvent( new IPhonePageScrollerEvents( IPhonePageScrollerEvents.PAGE_FOCUS_START, _nearestPage ) );
			}
		}
		
		public function get pageWidth():Number { return _pageWidth; }
		
		public function set pageWidth(value:Number):void 
		{
			_pageWidth = value;
		}
		
		/**
		 * The position, in a global view, of where the page must be when 
		 * fully shown
		 */
		public function get pagePosition():Number { return _pagePosition; }
		
		public function set pagePosition(value:Number):void 
		{
			_pagePosition = value;
		}
		
		public function get sensitiveness():Number { return _sensitiveness; }
		
		public function set sensitiveness(value:Number):void 
		{
			_sensitiveness = value;
		}
		
		public function get moving():Boolean { return _moving; }
	}	
}