/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBETest
{
   import PBLabs.Box2D.CollisionEvent;
   import PBLabs.Engine.Core.*;
   import PBLabs.Engine.Debug.Logger;
   import PBLabs.Engine.Entity.*;
   import PBLabs.Engine.Resource.ResourceManager;
   import PBLabs.MP3Sound.MP3Resource;
   
   import flash.geom.Point;
   import flash.media.Sound;

   public class DudeController extends EntityComponent implements ITickedObject
   {
      public var VelocityReference:PropertyReference;
      
      public function get Input():InputMap
      {
         return _inputMap;
      }
      
      public function set Input(value:InputMap):void
      {
         _inputMap = value;
         
         if (_inputMap != null)
         {
            _inputMap.AddBinding("GoLeft", _OnLeft);
            _inputMap.AddBinding("GoRight", _OnRight);
            _inputMap.AddBinding("Jump", _OnJump);
             _inputMap.AddBinding("AddShip", _OnNewShip);
         }
      }
      
      public function OnTick(tickRate:Number):void
      {
         var move:Number = _right - _left;
         var velocity:Point = Owner.GetProperty(VelocityReference);
         velocity.x = move * 100;
         
         if (_jump > 0)
         {
            //if (_sound != null)
            //   _sound.play();
            Logger.Print(this, "Jump!");
            trace("Jump!");
            velocity.y -= 200;
            _jump = 0;
         }
         
         if (_addShip > 0)
         {
         	 // Spawn a new ship somewhere.
            var ship:IEntity = TemplateManager.Instance.InstantiateEntity("Ship");
            ship.SetProperty(new PropertyReference("@Spatial.Position"), new Point(20 + Math.random() * 600, 20 + Math.random() * 400));
            ship.SetProperty(new PropertyReference("@Spatial.Rotation"), Math.random() *360);                  	         
         	Logger.Print(this, "Added one ship");
         	trace("Added ship");
         	_addShip = 0;
         }
         Owner.SetProperty(VelocityReference, velocity);
      }
      
      public function OnInterpolateTick(factor:Number):void
      {
      }
      
      protected override function _OnAdd():void
      {
         ProcessManager.Instance.AddTickedObject(this);
         ResourceManager.Instance.Load("../Assets/Sounds/testSound.mp3", MP3Resource, _OnSoundLoaded);
         
         Owner.EventDispatcher.addEventListener(CollisionEvent.COLLISION_EVENT, _OnCollision);
         Owner.EventDispatcher.addEventListener(CollisionEvent.COLLISION_STOPPED_EVENT, _OnCollisionEnd);
                  
      }
      
      protected override function _OnRemove():void
      {
         Owner.EventDispatcher.removeEventListener(CollisionEvent.COLLISION_EVENT, _OnCollision);
         Owner.EventDispatcher.removeEventListener(CollisionEvent.COLLISION_STOPPED_EVENT, _OnCollisionEnd);
         
         ResourceManager.Instance.Unload("../Assets/Sounds/testSound.mp3", MP3Resource);
         ProcessManager.Instance.RemoveTickedObject(this);
      }
      
      private function _OnCollision(event:CollisionEvent):void
      {
         if (ObjectTypeManager.Instance.DoesTypeOverlap(event.Collidee.CollisionType, "Platform"))
         {
            if (event.Normal.y > 0.7)
               _onGround++;
         }
         
         if (ObjectTypeManager.Instance.DoesTypeOverlap(event.Collider.CollisionType, "Platform"))
         {
            if (event.Normal.y < -0.7)
               _onGround++;
         }
      }
      
      private function _OnCollisionEnd(event:CollisionEvent):void
      {
         if (ObjectTypeManager.Instance.DoesTypeOverlap(event.Collidee.CollisionType, "Platform"))
         {
            if (event.Normal.y > 0.7)
               _onGround--;
         }
         
         if (ObjectTypeManager.Instance.DoesTypeOverlap(event.Collider.CollisionType, "Platform"))
         {
            if (event.Normal.y < -0.7)
               _onGround--;
         }
      }
      
      private function _OnSoundLoaded(resource:MP3Resource):void
      {
         _sound = resource.SoundObject;
      }
      
      private function _OnLeft(value:Number):void
      {
         _left = value;
      }
      
      private function _OnRight(value:Number):void
      {
         _right = value;
      }
      
      private function _OnJump(value:Number):void
      {
         if (_onGround > 0)
            _jump = value;
      }
      
      private function _OnNewShip(value:Number):void
      {
      	_addShip = value;
      }
      
      private var _sound:Sound = null;
      private var _inputMap:InputMap;
      private var _left:Number = 0;
      private var _right:Number = 0;
      private var _jump:Number = 0;
      private var _onGround:int = 0;
      private var _addShip:int = 0;
   }
}