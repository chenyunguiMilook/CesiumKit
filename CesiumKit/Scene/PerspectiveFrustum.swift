//
//  PerspectiveFrustum.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 22/08/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation

/**
* The viewing frustum is defined by 6 planes.
* Each plane is represented by a {@link Cartesian4} object, where the x, y, and z components
* define the unit vector normal to the plane, and the w component is the distance of the
* plane from the origin/camera position.
*
* @alias PerspectiveFrustum
* @constructor
*
* @see PerspectiveOffCenterFrustum
*
* @example
* var frustum = new Cesium.PerspectiveFrustum();
* frustum.aspectRatio = canvas.clientWidth / canvas.clientHeight;
* frustum.fov = Cesium.Math.PI_OVER_THREE;
* frustum.near = 1.0;
* frustum.far = 2.0;
*/
// FIXME: Frustum protocol
class PerspectiveFrustum/*: Frustum*/ {
    /**
    * The angle of the field of view (FOV), in radians.  This angle will be used
    * as the horizontal FOV if the width is greater than the height, otherwise
    * it will be the vertical FOV.
    * @type {Number}
    * @default undefined
    */
    var fov: Double {
        get  {
            return _fov
        }
        set (newFov) {
            _fov = newFov
            update()
        }
    }
    private var _fov: Double = 0.0
    
    /**
    * Gets the angle of the vertical field of view, in radians.
    * @memberof PerspectiveFrustum.prototype
    * @type {Number}
    * @default undefined
    */
    var fovy: Double {
        get  {
            return _fovy
        }
        set (newFovy) {
            _fovy = newFovy
            update()
        }
    }
    private var _fovy: Double = 0.0
    
    /**
    * The aspect ratio of the frustum's width to it's height.
    * @type {Number}
    * @default undefined
    */
    var aspectRatio: Double {
        get  {
            return _aspectRatio
        }
        set (newAspectRatio) {
            _aspectRatio = newAspectRatio
            update()
        }
    }
    private var _aspectRatio: Double = 1.0
    
    /**
    * The distance of the near plane.
    * @type {Number}
    * @default 1.0
    */
    var near: Double {
        get  {
            return _near
        }
        set (newNear) {
            _near = near
            update()
        }
    }
    private var _near: Double = 1.0
    
    /**
    * The distance of the far plane.
    * @type {Number}
    * @default 500000000.0
    */
    var far: Double {
        get  {
            return _far
        }
        set (newNear) {
            _far = far
            update()
        }
    }
    private var _far: Double = 500000000.0
    
    private var _offCenterFrustum = PerspectiveOffCenterFrustum()
    
    func update() {
        //assert(_fov != nil && aspectRatio != nil, "fov, aspectRatio, near, or far parameters are not set")
        
        
            assert(_fov >= 0 && _fov <= M_PI, "fov must be in the range [0, PI]")
            assert(_aspectRatio > 0, "aspectRatio must be positive")
            assert(_near > 0 && _near < _far, "near must be greater than zero and less than far")
            
            //_aspectRatio = aspectRatio
            //_fov = fov
            _fovy = aspectRatio <= 1.0 ? _fov : atan(tan(_fov * 0.5) / _aspectRatio) * 2.0
            //_near = near
            //_far = far
            
            _offCenterFrustum.top = _near * tan(0.5 * _fovy)
            _offCenterFrustum.bottom = -_offCenterFrustum.top
            _offCenterFrustum.right = _aspectRatio * _offCenterFrustum.top
            _offCenterFrustum.left = -_offCenterFrustum.right
            _offCenterFrustum.near = _near
            _offCenterFrustum.far = _far
        //}
    }
    
    /**
    * Gets the perspective projection matrix computed from the view frustum.
    * @memberof PerspectiveFrustum.prototype
    * @type {Matrix4}
    *
    * @see PerspectiveFrustum#infiniteProjectionMatrix
    */
    var projectionMatrix: Matrix4 {
        get {
            //update()
            return _offCenterFrustum.projectionMatrix
        }
    }
    
    /**
    * The perspective projection matrix computed from the view frustum with an infinite far plane.
    * @memberof PerspectiveFrustum.prototype
    * @type {Matrix4}
    *
    * @see PerspectiveFrustum#projectionMatrix
    */
    var infiniteProjectionMatrix: Matrix4 {
        get {
            //update()
            return _offCenterFrustum.infiniteProjectionMatrix
        }
    }
    
    /**
    * Creates a culling volume for this frustum.
    *
    * @param {Cartesian3} position The eye position.
    * @param {Cartesian3} direction The view direction.
    * @param {Cartesian3} up The up direction.
    * @returns {CullingVolume} A culling volume at the given position and orientation.
    *
    * @example
    * // Check if a bounding volume intersects the frustum.
    * var cullingVolume = frustum.computeCullingVolume(cameraPosition, cameraDirection, cameraUp);
    * var intersect = cullingVolume.computeVisibility(boundingVolume);
    */
    func computeCullingVolume (#position: Cartesian3, direction: Cartesian3, up: Cartesian3) -> CullingVolume {
        //update()
        return _offCenterFrustum.computeCullingVolume(position: position, direction: direction, up: up)
    }
    
    /**
    * Returns the pixel's width and height in meters.
    *
    * @param {Cartesian2} drawingBufferDimensions A {@link Cartesian2} with width and height in the x and y properties, respectively.
    * @param {Number} [distance=near plane distance] The distance to the near plane in meters.
    * @param {Cartesian2} [result] The object onto which to store the result.
    * @returns {Cartesian2} The modified result parameter or a new instance of {@link Cartesian2} with the pixel's width and height in the x and y properties, respectively.
    *
    * @exception {DeveloperError} drawingBufferDimensions.x must be greater than zero.
    * @exception {DeveloperError} drawingBufferDimensions.y must be greater than zero.
    *
    * @example
    * // Example 1
    * // Get the width and height of a pixel.
    * var pixelSize = camera.frustum.getPixelSize({
    *     width : canvas.clientWidth,
    *     height : canvas.clientHeight
    * });
    *
    * @example
    * // Example 2
    * // Get the width and height of a pixel if the near plane was set to 'distance'.
    * // For example, get the size of a pixel of an image on a billboard.
    * var position = camera.position;
    * var direction = camera.direction;
    * var toCenter = Cesium.Cartesian3.subtract(primitive.boundingVolume.center, position, new Cesium.Cartesian3());      // vector from camera to a primitive
    * var toCenterProj = Cesium.Cartesian3.multiplyByScalar(direction, Cesium.Cartesian3.dot(direction, toCenter)); // project vector onto camera direction vector
    * var distance = Cesium.Cartesian3.magnitude(toCenterProj);
    * var pixelSize = camera.frustum.getPixelSize({
    *     width : canvas.clientWidth,
    *     height : canvas.clientHeight
    * }, distance);
    */
    func pixelSize (#drawingBufferDimensions: Cartesian2, distance: Double) -> Cartesian2 {
        //update()
        return _offCenterFrustum.pixelSize(drawingBufferDimensions, distance: distance)
    }
    
    /**
    * Returns a duplicate of a PerspectiveFrustum instance.
    *
    * @param {PerspectiveFrustum} [result] The object onto which to store the result.
    * @returns {PerspectiveFrustum} The modified result parameter or a new PerspectiveFrustum instance if one was not provided.
    */
    /*PerspectiveFrustum.prototype.clone = function(result) {
    if (!defined(result)) {
    result = new PerspectiveFrustum();
    }
    
    result.aspectRatio = this.aspectRatio;
    result.fov = this.fov;
    result.near = this.near;
    result.far = this.far;
    
    // force update of clone to compute matrices
    result._aspectRatio = undefined;
    result._fov = undefined;
    result._near = undefined;
    result._far = undefined;
    
    this._offCenterFrustum.clone(result._offCenterFrustum);
    
    return result;
    };*/
    
    /**
    * Compares the provided PerspectiveFrustum componentwise and returns
    * <code>true</code> if they are equal, <code>false</code> otherwise.
    *
    * @param {PerspectiveFrustum} [other] The right hand side PerspectiveFrustum.
    * @returns {Boolean} <code>true</code> if they are equal, <code>false</code> otherwise.
    */
    /*
    PerspectiveFrustum.prototype.equals = function(other) {
    if (!defined(other)) {
    return false;
    }
    
    update(this);
    update(other);
    
    return (this.fov === other.fov &&
    this.aspectRatio === other.aspectRatio &&
    this.near === other.near &&
    this.far === other.far &&
    this._offCenterFrustum.equals(other._offCenterFrustum));
    };
    */
}