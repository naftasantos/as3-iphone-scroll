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

-- iPhone Page Scroll Bar in AS3
-- Copyright 2010 Naftali Andrade Santos
-- naftali.a.santos@gmail.com
-- http://dev.naftali.com.br

****************************************************************************/
package br.com.naftali.components
{
	import com.shinedraw.controls.IPhoneScroll;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/**
	 * ScrollBar
	 * represents the position and scrolls the IPhoneScroll class
	 * @author Naftali Andrade
	 */
	public final class IPhoneScrollBar
	{
		private var _mcContent:MovieClip;
		private var _iphoneScroll:IPhoneScroll;
		private var _stage:Stage;
		private var _diff:Number;
		private var _isMouseDown:Boolean;
		
		public function IPhoneScrollBar( pContent:MovieClip, pIphone:IPhoneScroll, pStage:Stage ):void
		{
			_mcContent 		= pContent;
			_iphoneScroll 	= pIphone;
			_stage			= pStage;
			
			_mcContent.mcScroll.addEventListener( MouseEvent.MOUSE_DOWN, onScrollMouseDown );
		}
		
		public function process( p_transport:Object ):void
		{
			if ( _iphoneScroll.started )
			{
				var perc:Number = _iphoneScroll.percPosition;
				
				if ( perc < 0 ) 	perc = 0;
				if ( perc > 1 ) 	perc = 1;
				
				var pos:Number = ( _mcContent.mcMax.y - _mcContent.mcMin.y ) * perc;
				
				_mcContent.mcScroll.y = _mcContent.mcMin.y + pos;
			}
			else if ( _isMouseDown )
			{
				var localPos:Point = _mcContent.globalToLocal( new Point( _stage.mouseX, _stage.mouseY ) );
				
				_mcContent.mcScroll.y = localPos.y - _diff;
				
				alignToBounds();
				setContentPos();
			}
		}
		
		private function setContentPos():void
		{
			var perc:Number = getPosPerc();
			
			_iphoneScroll.myScrollElement.y = ( ( -_iphoneScroll.myScrollElement.height + _iphoneScroll.canvasHeight ) * perc );
		}
		
		private function alignToBounds():void
		{
			if ( _mcContent.mcScroll.y < _mcContent.mcMin.y )
				_mcContent.mcScroll.y = _mcContent.mcMin.y;
			else if ( _mcContent.mcScroll.y > _mcContent.mcMax.y )
				_mcContent.mcScroll.y = _mcContent.mcMax.y;
		}
		
		private function getPosPerc():Number
		{
			var itemY:Number = _mcContent.mcScroll.y - _mcContent.mcMin.y;
			var size:Number = _mcContent.mcMin.y + _mcContent.mcMax.y;
			
			return itemY / size;
		}
		
		public function release():void
		{
			_mcContent.mcScroll.removeEventListener( MouseEvent.MOUSE_DOWN, onScrollMouseDown );
			_stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			
			_mcContent 		= null;
			_iphoneScroll 	= null;
		}
		
		private function onScrollMouseDown(e:MouseEvent):void 
		{
			_stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			_isMouseDown = true;
			
			var globalPos:Point = _mcContent.localToGlobal( new Point( _mcContent.mcScroll.x, _mcContent.mcScroll.y ) );
			_diff = _stage.mouseY - globalPos.y;
			
			_iphoneScroll.stop();
		}
		
		private function onStageMouseUp(e:MouseEvent):void 
		{
			_stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			_isMouseDown = false;
			
			_iphoneScroll.start();
		}
		
		public function get content():MovieClip { return _mcContent; }
	}
	
}