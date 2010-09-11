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

-- iPhone Page Scroll Events in AS3
-- Copyright 2010 Naftali Andrade Santos
-- naftali.a.santos@gmail.com
-- http://dev.naftali.com.br

****************************************************************************/
package br.com.naftali.components
{
	import flash.events.Event;
	
	/**
	 * The events for the IPhonePageScroller class
	 * @author Naftali Andrade
	 */
	public class IPhonePageScrollerEvents extends Event
	{
		private var _transport:Object;
		
		public static const PAGE_FOCUS_END:String 	= "iphone_events_PAGE_FOCUS_END";
		public static const PAGE_FOCUS_START:String = "iphone_events_PAGE_FOCUS_START";
		
		public function IPhonePageScrollerEvents( type:String, pTransport:Object = null, bubbles:Boolean = false, cancelable:Boolean = false ):void
		{
			super( type, bubbles, cancelable );
			
			_transport = pTransport;
		}
		
		public function get transport():Object { return _transport; }
	}
	
}