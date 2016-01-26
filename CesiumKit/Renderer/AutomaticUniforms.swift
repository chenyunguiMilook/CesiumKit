//
//  AutomaticUniforms.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 25/11/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//


import GLSLOptimizer

typealias AutomaticUniformFunc = (uniformState: UniformState) -> [UInt8]

struct AutomaticUniform {
    let size: Int
    let datatype: UniformDataType
    let getValue: AutomaticUniformFunc
    
    func declaration (name: String) -> String {
        var declaration = "uniform \(datatype.declarationString) \(name)"
        
        if size == 1 {
            declaration += ";"
        } else {
            declaration += "[\(size)];"
        }
        
        return declaration
    }
}

/**
* @private
*/


let AutomaticUniforms: [String: AutomaticUniform] = [
    /**
    * An automatic GLSL uniform containing the viewport's <code>x</code>, <code>y</code>, <code>width</code>,
    * and <code>height</code> properties in an <code>vec4</code>'s <code>x</code>, <code>y</code>, <code>z</code>,
    * and <code>w</code> components, respectively.
    *
    * @alias czm_viewport
    * @glslUniform
    *
    * @see Context#getViewport
    *
    * @example
    * // GLSL declaration
    * uniform vec4 czm_viewport;
    *
    * // Scale the window coordinate components to [0, 1] by dividing
    * // by the viewport's width and height.
    * vec2 v = gl_FragCoord.xy / czm_viewport.zw;
    */
    "czm_viewport": AutomaticUniform(
        size: 1,
        datatype: UniformDataType.FloatVec4,
        getValue: { (uniformState: UniformState) -> [UInt8] in
            return uniformState.viewportCartesian4.simdType
        }
    ),
    
    /**
    * An automatic GLSL uniform representing a 4x4 orthographic projection matrix that
    * transforms window coordinates to clip coordinates.  Clip coordinates is the
    * coordinate system for a vertex shader's <code>gl_Position</code> output.
    * <br /><br />
    * This transform is useful when a vertex shader inputs or manipulates window coordinates
    * as done by {@link BillboardCollection}.
    * <br /><br />
    * Do not confuse {@link czm_viewportTransformation} with <code>czm_viewportOrthographic</code>.
    * The former transforms from normalized device coordinates to window coordinates; the later transforms
    * from window coordinates to clip coordinates, and is often used to assign to <code>gl_Position</code>.
    *
    * @alias czm_viewportOrthographic
    * @glslUniform
    *
    * @see UniformState#viewportOrthographic
    * @see czm_viewport
    * @see czm_viewportTransformation
    * @see BillboardCollection
    *
    * @example
    * // GLSL declaration
    * uniform mat4 czm_viewportOrthographic;
    *
    * // Example
    * gl_Position = czm_viewportOrthographic * vec4(windowPosition, 0.0, 1.0);
    */
    "czm_viewportOrthographic":  AutomaticUniform(
        size: 1,
        datatype: UniformDataType.FloatMatrix4,
        getValue: { (uniformState: UniformState) -> UniformSourceType in
            uniformState.viewportOrthographic
        }
    ),
    
    /**
    * An automatic GLSL uniform representing a 4x4 transformation matrix that
    * transforms normalized device coordinates to window coordinates.  The context's
    * full viewport is used, and the depth range is assumed to be <code>near = 0</code>
    * and <code>far = 1</code>.
    * <br /><br />
    * This transform is useful when there is a need to manipulate window coordinates
    * in a vertex shader as done by {@link BillboardCollection}.  In many cases,
    * this matrix will not be used directly; instead, {@link czm_modelToWindowCoordinates}
    * will be used to transform directly from model to window coordinates.
    * <br /><br />
    * Do not confuse <code>czm_viewportTransformation</code> with {@link czm_viewportOrthographic}.
    * The former transforms from normalized device coordinates to window coordinates; the later transforms
    * from window coordinates to clip coordinates, and is often used to assign to <code>gl_Position</code>.
    *
    * @alias czm_viewportTransformation
    * @glslUniform
    *
    * @see UniformState#viewportTransformation
    * @see czm_viewport
    * @see czm_viewportOrthographic
    * @see czm_modelToWindowCoordinates
    * @see BillboardCollection
    *
    * @example
    * // GLSL declaration
    * uniform mat4 czm_viewportTransformation;
    *
    * // Use czm_viewportTransformation as part of the
    * // transform from model to window coordinates.
    * vec4 q = czm_modelViewProjection * positionMC;               // model to clip coordinates
    * q.xyz /= q.w;                                                // clip to normalized device coordinates (ndc)
    * q.xyz = (czm_viewportTransformation * vec4(q.xyz, 1.0)).xyz; // ndc to window coordinates
    */
    
    "czm_viewportTransformation": AutomaticUniform(
        size: 1,
        datatype: UniformDataType.FloatMatrix4,
        getValue: { (uniformState: UniformState) -> UniformSourceType in
            return uniformState.viewportTransformation
        }
    ),
    /*
    /**
             * An automatic GLSL uniform representing the depth after
             * only the globe has been rendered and packed into an RGBA texture.
             *
             * @private
             *
             * @alias czm_globeDepthTexture
             * @glslUniform
             *
             * @example
             * // GLSL declaration
             * uniform sampler2D czm_globeDepthTexture;
             *
             * // Get the depth at the current fragment
             * vec2 coords = gl_FragCoord.xy / czm_viewport.zw;
             * float depth = czm_unpackDepth(texture2D(czm_globeDepthTexture, coords));
             */
            czm_globeDepthTexture : new AutomaticUniform({
                size : 1,
                datatype : WebGLConstants.SAMPLER_2D,
                getValue : function(uniformState) {
                    return uniformState.globeDepthTexture;
                }
            }),
    
    /**
    * An automatic GLSL uniform representing a 4x4 model transformation matrix that
    * transforms model coordinates to world coordinates.
    *
    * @alias czm_model
    * @glslUniform
    *
    * @see UniformState#model
    * @see czm_inverseModel
    * @see czm_modelView
    * @see czm_modelViewProjection
    *
    * @example
    * // GLSL declaration
    * uniform mat4 czm_model;
    *
    * // Example
    * vec4 worldPosition = czm_model * modelPosition;
    */
    czm_model : new AutomaticUniform({
    size : 1,
    datatype : WebGLRenderingContext.FLOAT_MAT4,
    getValue : function(uniformState) {
    return uniformState.model; as Any
    }
    }),
    
    /**
    * An automatic GLSL uniform representing a 4x4 model transformation matrix that
    * transforms world coordinates to model coordinates.
    *
    * @alias czm_inverseModel
    * @glslUniform
    *
    * @see UniformState#inverseModel
    * @see czm_model
    * @see czm_inverseModelView
    *
    * @example
    * // GLSL declaration
    * uniform mat4 czm_inverseModel;
    *
    * // Example
    * vec4 modelPosition = czm_inverseModel * worldPosition;
    */
    czm_inverseModel : new AutomaticUniform({
    size : 1,
    datatype : WebGLRenderingContext.FLOAT_MAT4,
    getValue : function(uniformState) {
    return uniformState.inverseModel; as Any
    }
    }),
    */
    /**
    * An automatic GLSL uniform representing a 4x4 view transformation matrix that
    * transforms world coordinates to eye coordinates.
    *
    * @alias czm_view
    * @glslUniform
    *
    * @see UniformState#view
    * @see czm_viewRotation
    * @see czm_modelView
    * @see czm_viewProjection
    * @see czm_modelViewProjection
    * @see czm_inverseView
    *
    * @example
    * // GLSL declaration
    * uniform mat4 czm_view;
    *
    * // Example
    * vec4 eyePosition = czm_view * worldPosition;
    */
    "czm_view": AutomaticUniform(
        size: 1,
        datatype: UniformDataType.FloatMatrix4,
        getValue: { (uniformState: UniformState) -> UniformSourceType in
            return uniformState.view
        }
    ),
    /*
    /**
    * An automatic GLSL uniform representing a 4x4 view transformation matrix that
    * transforms 3D world coordinates to eye coordinates.  In 3D mode, this is identical to
    * {@link czm_view}, but in 2D and Columbus View it represents the view matrix
    * as if the camera were at an equivalent location in 3D mode.  This is useful for lighting
    * 2D and Columbus View in the same way that 3D is lit.
    *
    * @alias czm_view3D
    * @glslUniform
    *
    * @see UniformState#view3D
    * @see czm_view
    *
    * @example
    * // GLSL declaration
    * uniform mat4 czm_view3D;
    *
    * // Example
    * vec4 eyePosition3D = czm_view3D * worldPosition3D;
    */
    czm_view3D : new AutomaticUniform({
    size : 1,
    datatype : WebGLRenderingContext.FLOAT_MAT4,
    getValue : function(uniformState) {
    return uniformState.view3D; as Any
    }
    }),
    */
    /**
    * An automatic GLSL uniform representing a 3x3 view rotation matrix that
    * transforms vectors in world coordinates to eye coordinates.
    *
    * @alias czm_viewRotation
    * @glslUniform
    *
    * @see UniformState#viewRotation
    * @see czm_view
    * @see czm_inverseView
    * @see czm_inverseViewRotation
    *
    * @example
    * // GLSL declaration
    * uniform mat3 czm_viewRotation;
    *
    * // Example
    * vec3 eyeVector = czm_viewRotation * worldVector;
    */
    "czm_viewRotation": AutomaticUniform(
        size: 1,
        datatype: .FloatMatrix3,
        getValue: { (uniformState: UniformState) -> UniformSourceType in
            return uniformState.viewRotation
        }
    ),
    /*
    /**
    * An automatic GLSL uniform representing a 3x3 view rotation matrix that
    * transforms vectors in 3D world coordinates to eye coordinates.  In 3D mode, this is identical to
    * {@link czm_viewRotation}, but in 2D and Columbus View it represents the view matrix
    * as if the camera were at an equivalent location in 3D mode.  This is useful for lighting
    * 2D and Columbus View in the same way that 3D is lit.
    *
    * @alias czm_viewRotation3D
    * @glslUniform
    *
    * @see UniformState#viewRotation3D
    * @see czm_viewRotation
    *
    * @example
    * // GLSL declaration
    * uniform mat3 czm_viewRotation3D;
    *
    * // Example
    * vec3 eyeVector = czm_viewRotation3D * worldVector;
    */
    czm_viewRotation3D : new AutomaticUniform({
    size : 1,
    datatype : WebGLRenderingContext.FLOAT_MAT3,
    getValue : function(uniformState) {
    return uniformState.viewRotation3D; as Any
    }
    }),
    
    /**
    * An automatic GLSL uniform representing a 4x4 transformation matrix that
    * transforms from eye coordinates to world coordinates.
    *
    * @alias czm_inverseView
    * @glslUniform
    *
    * @see UniformState#inverseView
    * @see czm_view
    * @see czm_inverseNormal
    *
    * @example
    * // GLSL declaration
    * uniform mat4 czm_inverseView;
    *
    * // Example
    * vec4 worldPosition = czm_inverseView * eyePosition;
    */
    czm_inverseView : new AutomaticUniform({
    size : 1,
    datatype : WebGLRenderingContext.FLOAT_MAT4,
    getValue : function(uniformState) {
    return uniformState.inverseView; as Any
    }
    }),
    
    /**
    * An automatic GLSL uniform representing a 4x4 transformation matrix that
    * transforms from 3D eye coordinates to world coordinates.  In 3D mode, this is identical to
    * {@link czm_inverseView}, but in 2D and Columbus View it represents the inverse view matrix
    * as if the camera were at an equivalent location in 3D mode.  This is useful for lighting
    * 2D and Columbus View in the same way that 3D is lit.
    *
    * @alias czm_inverseView3D
    * @glslUniform
    *
    * @see UniformState#inverseView3D
    * @see czm_inverseView
    *
    * @example
    * // GLSL declaration
    * uniform mat4 czm_inverseView3D;
    *
    * // Example
    * vec4 worldPosition = czm_inverseView3D * eyePosition;
    */
    czm_inverseView3D : new AutomaticUniform({
    size : 1,
    datatype : WebGLRenderingContext.FLOAT_MAT4,
    getValue : function(uniformState) {
    return uniformState.inverseView3D; as Any
    }
    }),
    
    /**
    * An automatic GLSL uniform representing a 3x3 rotation matrix that
    * transforms vectors from eye coordinates to world coordinates.
    *
    * @alias czm_inverseViewRotation
    * @glslUniform
    *
    * @see UniformState#inverseView
    * @see czm_view
    * @see czm_viewRotation
    * @see czm_inverseViewRotation
    *
    * @example
    * // GLSL declaration
    * uniform mat3 czm_inverseViewRotation;
    *
    * // Example
    * vec4 worldVector = czm_inverseViewRotation * eyeVector;
    */
    czm_inverseViewRotation : new AutomaticUniform({
    size : 1,
    datatype : WebGLRenderingContext.FLOAT_MAT3,
    getValue : function(uniformState) {
    return uniformState.inverseViewRotation; as Any
    }
    }),
    
    /**
    * An automatic GLSL uniform representing a 3x3 rotation matrix that
    * transforms vectors from 3D eye coordinates to world coordinates.  In 3D mode, this is identical to
    * {@link czm_inverseViewRotation}, but in 2D and Columbus View it represents the inverse view matrix
    * as if the camera were at an equivalent location in 3D mode.  This is useful for lighting
    * 2D and Columbus View in the same way that 3D is lit.
    *
    * @alias czm_inverseViewRotation3D
    * @glslUniform
    *
    * @see UniformState#inverseView3D
    * @see czm_inverseViewRotation
    *
    * @example
    * // GLSL declaration
    * uniform mat3 czm_inverseViewRotation3D;
    *
    * // Example
    * vec4 worldVector = czm_inverseViewRotation3D * eyeVector;
    */
    czm_inverseViewRotation3D : new AutomaticUniform({
    size : 1,
    datatype : WebGLRenderingContext.FLOAT_MAT3,
    getValue : function(uniformState) {
    return uniformState.inverseViewRotation3D; as Any
    }
    }),
    */
    /**
    * An automatic GLSL uniform representing a 4x4 projection transformation matrix that
    * transforms eye coordinates to clip coordinates.  Clip coordinates is the
    * coordinate system for a vertex shader's <code>gl_Position</code> output.
    *
    * @alias czm_projection
    * @glslUniform
    *
    * @see UniformState#projection
    * @see czm_viewProjection
    * @see czm_modelViewProjection
    * @see czm_infiniteProjection
    *
    * @example
    * // GLSL declaration
    * uniform mat4 czm_projection;
    *
    * // Example
    * gl_Position = czm_projection * eyePosition;
    */
    "czm_projection": AutomaticUniform(
        size: 1,
        datatype: UniformDataType.FloatMatrix4,
        getValue: { (uniformState: UniformState) -> UniformSourceType in
            return uniformState.projection
        }
    ),
    
    /**
    * An automatic GLSL uniform representing a 4x4 inverse projection transformation matrix that
    * transforms from clip coordinates to eye coordinates. Clip coordinates is the
    * coordinate system for a vertex shader's <code>gl_Position</code> output.
    *
    * @alias czm_inverseProjection
    * @glslUniform
    *
    * @see UniformState#inverseProjection
    * @see czm_projection
    *
    * @example
    * // GLSL declaration
    * uniform mat4 czm_inverseProjection;
    *
    * // Example
    * vec4 eyePosition = czm_inverseProjection * clipPosition;
    */
    "czm_inverseProjection": AutomaticUniform(
        size : 1,
        datatype : UniformDataType.FloatMatrix4,
        getValue: { (uniformState: UniformState) -> UniformSourceType in
            return uniformState.inverseProjection
        }
    ),
    /*
    /**
    * @private
    */
    czm_inverseProjectionOIT : new AutomaticUniform({
    size : 1,
    datatype : WebGLRenderingContext.FLOAT_MAT4,
    getValue : function(uniformState) {
    return uniformState.inverseProjectionOIT; as Any
    }
    }),
    
    /**
    * An automatic GLSL uniform representing a 4x4 projection transformation matrix with the far plane at infinity,
    * that transforms eye coordinates to clip coordinates.  Clip coordinates is the
    * coordinate system for a vertex shader's <code>gl_Position</code> output.  An infinite far plane is used
    * in algorithms like shadow volumes and GPU ray casting with proxy geometry to ensure that triangles
    * are not clipped by the far plane.
    *
    * @alias czm_infiniteProjection
    * @glslUniform
    *
    * @see UniformState#infiniteProjection
    * @see czm_projection
    * @see czm_modelViewInfiniteProjection
    *
    * @example
    * // GLSL declaration
    * uniform mat4 czm_infiniteProjection;
    *
    * // Example
    * gl_Position = czm_infiniteProjection * eyePosition;
    */
    czm_infiniteProjection : new AutomaticUniform({
    size : 1,
    datatype : WebGLRenderingContext.FLOAT_MAT4,
    getValue : function(uniformState) {
    return uniformState.infiniteProjection; as Any
    }
    }),
    */
    /**
    * An automatic GLSL uniform representing a 4x4 model-view transformation matrix that
    * transforms model coordinates to eye coordinates.
    * <br /><br />
    * Positions should be transformed to eye coordinates using <code>czm_modelView</code> and
    * normals should be transformed using {@link czm_normal}.
    *
    * @alias czm_modelView
    * @glslUniform
    *
    * @see UniformState#modelView
    * @see czm_model
    * @see czm_view
    * @see czm_modelViewProjection
    * @see czm_normal
    *
    * @example
    * // GLSL declaration
    * uniform mat4 czm_modelView;
    *
    * // Example
    * vec4 eyePosition = czm_modelView * modelPosition;
    *
    * // The above is equivalent to, but more efficient than:
    * vec4 eyePosition = czm_view * czm_model * modelPosition;
    */
    "czm_modelView" : AutomaticUniform(
        size : 1,
        datatype: UniformDataType.FloatMatrix4,
        getValue: { (uniformState: UniformState) -> UniformSourceType in
            return uniformState.modelView
        }
    ),
    
    /**
    * An automatic GLSL uniform representing a 4x4 model-view transformation matrix that
    * transforms 3D model coordinates to eye coordinates.  In 3D mode, this is identical to
    * {@link czm_modelView}, but in 2D and Columbus View it represents the model-view matrix
    * as if the camera were at an equivalent location in 3D mode.  This is useful for lighting
    * 2D and Columbus View in the same way that 3D is lit.
    * <br /><br />
    * Positions should be transformed to eye coordinates using <code>czm_modelView3D</code> and
    * normals should be transformed using {@link czm_normal3D}.
    *
    * @alias czm_modelView3D
    * @glslUniform
    *
    * @see UniformState#modelView3D
    * @see czm_modelView
    *
    * @example
    * // GLSL declaration
    * uniform mat4 czm_modelView3D;
    *
    * // Example
    * vec4 eyePosition = czm_modelView3D * modelPosition;
    *
    * // The above is equivalent to, but more efficient than:
    * vec4 eyePosition = czm_view3D * czm_model * modelPosition;
    */
    "czm_modelView3D": AutomaticUniform(
        size: 1,
        datatype: UniformDataType.FloatMatrix4,
        getValue: { (uniformState: UniformState) -> UniformSourceType in
            return uniformState.modelView3D
        }
    ),
    /*
    /**
    * An automatic GLSL uniform representing a 4x4 model-view transformation matrix that
    * transforms model coordinates, relative to the eye, to eye coordinates.  This is used
    * in conjunction with {@link czm_translateRelativeToEye}.
    *
    * @alias czm_modelViewRelativeToEye
    * @glslUniform
    *
    * @example
    * // GLSL declaration
    * uniform mat4 czm_modelViewRelativeToEye;
    *
    * // Example
    * attribute vec3 positionHigh;
    * attribute vec3 positionLow;
    *
    * void main()
    * {
    *   vec4 p = czm_translateRelativeToEye(positionHigh, positionLow);
    *   gl_Position = czm_projection * (czm_modelViewRelativeToEye * p);
    * }
    *
    * @see czm_modelViewProjectionRelativeToEye
    * @see czm_translateRelativeToEye
    * @see EncodedCartesian3
    */
    czm_modelViewRelativeToEye : new AutomaticUniform({
    size : 1,
    datatype : WebGLRenderingContext.FLOAT_MAT4,
    getValue : function(uniformState) {
    return uniformState.modelViewRelativeToEye; as Any
    }
    }),
    */
    /**
    * An automatic GLSL uniform representing a 4x4 transformation matrix that
    * transforms from eye coordinates to model coordinates.
    *
    * @alias czm_inverseModelView
    * @glslUniform
    *
    * @see UniformState#inverseModelView
    * @see czm_modelView
    *
    * @example
    * // GLSL declaration
    * uniform mat4 czm_inverseModelView;
    *
    * // Example
    * vec4 modelPosition = czm_inverseModelView * eyePosition;
    */
    "czm_inverseModelView" : AutomaticUniform(
        size : 1,
        datatype: UniformDataType.FloatMatrix4,
        getValue: { (uniformState: UniformState) -> UniformSourceType in
            return uniformState.inverseModelView
        }
    ),
    /*
    /**
    * An automatic GLSL uniform representing a 4x4 transformation matrix that
    * transforms from eye coordinates to 3D model coordinates.  In 3D mode, this is identical to
    * {@link czm_inverseModelView}, but in 2D and Columbus View it represents the inverse model-view matrix
    * as if the camera were at an equivalent location in 3D mode.  This is useful for lighting
    * 2D and Columbus View in the same way that 3D is lit.
    *
    * @alias czm_inverseModelView3D
    * @glslUniform
    *
    * @see UniformState#inverseModelView
    * @see czm_inverseModelView
    * @see czm_modelView3D
    *
    * @example
    * // GLSL declaration
    * uniform mat4 czm_inverseModelView3D;
    *
    * // Example
    * vec4 modelPosition = czm_inverseModelView3D * eyePosition;
    */
    czm_inverseModelView3D : new AutomaticUniform({
    size : 1,
    datatype : WebGLRenderingContext.FLOAT_MAT4,
    getValue : function(uniformState) {
    return uniformState.inverseModelView3D; as Any
    }
    }),
    
    /**
    * An automatic GLSL uniform representing a 4x4 view-projection transformation matrix that
    * transforms world coordinates to clip coordinates.  Clip coordinates is the
    * coordinate system for a vertex shader's <code>gl_Position</code> output.
    *
    * @alias czm_viewProjection
    * @glslUniform
    *
    * @see UniformState#viewProjection
    * @see czm_view
    * @see czm_projection
    * @see czm_modelViewProjection
    * @see czm_inverseViewProjection
    *
    * @example
    * // GLSL declaration
    * uniform mat4 czm_viewProjection;
    *
    * // Example
    * vec4 gl_Position = czm_viewProjection * czm_model * modelPosition;
    *
    * // The above is equivalent to, but more efficient than:
    * gl_Position = czm_projection * czm_view * czm_model * modelPosition;
    */
    czm_viewProjection : new AutomaticUniform({
    size : 1,
    datatype : WebGLRenderingContext.FLOAT_MAT4,
    getValue : function(uniformState) {
    return uniformState.viewProjection; as Any
    }
    }),
    
    /**
    * An automatic GLSL uniform representing a 4x4 view-projection transformation matrix that
    * transforms clip coordinates to world coordinates.  Clip coordinates is the
    * coordinate system for a vertex shader's <code>gl_Position</code> output.
    *
    * @alias czm_inverseViewProjection
    * @glslUniform
    *
    * @see UniformState#inverseViewProjection
    * @see czm_viewProjection
    *
    * @example
    * // GLSL declaration
    * uniform mat4 czm_inverseViewProjection;
    *
    * // Example
    * vec4 worldPosition = czm_inverseViewProjection * clipPosition;
    */
    czm_inverseViewProjection : new AutomaticUniform({
    size : 1,
    datatype : WebGLRenderingContext.FLOAT_MAT4,
    getValue : function(uniformState) {
    return uniformState.inverseViewProjection; as Any
    }
    }),
    */
    /**
    * An automatic GLSL uniform representing a 4x4 model-view-projection transformation matrix that
    * transforms model coordinates to clip coordinates.  Clip coordinates is the
    * coordinate system for a vertex shader's <code>gl_Position</code> output.
    *
    * @alias czm_modelViewProjection
    * @glslUniform
    *
    * @see UniformState#modelViewProjection
    * @see czm_model
    * @see czm_view
    * @see czm_projection
    * @see czm_modelView
    * @see czm_viewProjection
    * @see czm_modelViewInfiniteProjection
    * @see czm_inverseModelViewProjection
    *
    * @example
    * // GLSL declaration
    * uniform mat4 czm_modelViewProjection;
    *
    * // Example
    * vec4 gl_Position = czm_modelViewProjection * modelPosition;
    *
    * // The above is equivalent to, but more efficient than:
    * gl_Position = czm_projection * czm_view * czm_model * modelPosition;
    */
    "czm_modelViewProjection": AutomaticUniform(
        size : 1,
        datatype: UniformDataType.FloatMatrix4,
        getValue: { (uniformState: UniformState) -> UniformSourceType in
            return uniformState.modelViewProjection
        }
    ),
    /*
    /**
    * An automatic GLSL uniform representing a 4x4 inverse model-view-projection transformation matrix that
    * transforms clip coordinates to model coordinates.  Clip coordinates is the
    * coordinate system for a vertex shader's <code>gl_Position</code> output.
    *
    * @alias czm_inverseModelViewProjection
    * @glslUniform
    *
    * @see UniformState#modelViewProjection
    * @see czm_modelViewProjection
    *
    * @example
    * // GLSL declaration
    * uniform mat4 czm_inverseModelViewProjection;
    *
    * // Example
    * vec4 modelPosition = czm_inverseModelViewProjection * clipPosition;
    */
    czm_inverseModelViewProjection : new AutomaticUniform({
    size : 1,
    datatype : WebGLRenderingContext.FLOAT_MAT4,
    getValue : function(uniformState) {
    return uniformState.inverseModelViewProjection; as Any
    }
    }),
    
    /**
    * An automatic GLSL uniform representing a 4x4 model-view-projection transformation matrix that
    * transforms model coordinates, relative to the eye, to clip coordinates.  Clip coordinates is the
    * coordinate system for a vertex shader's <code>gl_Position</code> output.  This is used in
    * conjunction with {@link czm_translateRelativeToEye}.
    *
    * @alias czm_modelViewProjectionRelativeToEye
    * @glslUniform
    *
    * @example
    * // GLSL declaration
    * uniform mat4 czm_modelViewProjectionRelativeToEye;
    *
    * // Example
    * attribute vec3 positionHigh;
    * attribute vec3 positionLow;
    *
    * void main()
    * {
    *   vec4 p = czm_translateRelativeToEye(positionHigh, positionLow);
    *   gl_Position = czm_modelViewProjectionRelativeToEye * p;
    * }
    *
    * @see czm_modelViewRelativeToEye
    * @see czm_translateRelativeToEye
    * @see EncodedCartesian3
    */
    czm_modelViewProjectionRelativeToEye : new AutomaticUniform({
    size : 1,
    datatype : WebGLRenderingContext.FLOAT_MAT4,
    getValue : function(uniformState) {
    return uniformState.modelViewProjectionRelativeToEye; as Any
    }
    }),
    
    /**
    * An automatic GLSL uniform representing a 4x4 model-view-projection transformation matrix that
    * transforms model coordinates to clip coordinates.  Clip coordinates is the
    * coordinate system for a vertex shader's <code>gl_Position</code> output.  The projection matrix places
    * the far plane at infinity.  This is useful in algorithms like shadow volumes and GPU ray casting with
    * proxy geometry to ensure that triangles are not clipped by the far plane.
    *
    * @alias czm_modelViewInfiniteProjection
    * @glslUniform
    *
    * @see UniformState#modelViewInfiniteProjection
    * @see czm_model
    * @see czm_view
    * @see czm_infiniteProjection
    * @see czm_modelViewProjection
    *
    * @example
    * // GLSL declaration
    * uniform mat4 czm_modelViewInfiniteProjection;
    *
    * // Example
    * vec4 gl_Position = czm_modelViewInfiniteProjection * modelPosition;
    *
    * // The above is equivalent to, but more efficient than:
    * gl_Position = czm_infiniteProjection * czm_view * czm_model * modelPosition;
    */
    czm_modelViewInfiniteProjection : new AutomaticUniform({
    size : 1,
    datatype : WebGLRenderingContext.FLOAT_MAT4,
    getValue : function(uniformState) {
    return uniformState.modelViewInfiniteProjection; as Any
    }
    }),
    */
    /**
    * An automatic GLSL uniform representing a 3x3 normal transformation matrix that
    * transforms normal vectors in model coordinates to eye coordinates.
    * <br /><br />
    * Positions should be transformed to eye coordinates using {@link czm_modelView} and
    * normals should be transformed using <code>czm_normal</code>.
    *
    * @alias czm_normal
    * @glslUniform
    *
    * @see UniformState#normal
    * @see czm_inverseNormal
    * @see czm_modelView
    *
    * @example
    * // GLSL declaration
    * uniform mat3 czm_normal;
    *
    * // Example
    * vec3 eyeNormal = czm_normal * normal;
    */
    "czm_normal": AutomaticUniform(
        size : 1,
        datatype : UniformDataType.FloatMatrix3,
        getValue: { (uniformState: UniformState) -> UniformSourceType in
            return uniformState.normal
        }
    ),
    
    /**
    * An automatic GLSL uniform representing a 3x3 normal transformation matrix that
    * transforms normal vectors in 3D model coordinates to eye coordinates.
    * In 3D mode, this is identical to
    * {@link czm_normal}, but in 2D and Columbus View it represents the normal transformation
    * matrix as if the camera were at an equivalent location in 3D mode.  This is useful for lighting
    * 2D and Columbus View in the same way that 3D is lit.
    * <br /><br />
    * Positions should be transformed to eye coordinates using {@link czm_modelView3D} and
    * normals should be transformed using <code>czm_normal3D</code>.
    *
    * @alias czm_normal3D
    * @glslUniform
    *
    * @see UniformState#normal3D
    * @see czm_normal
    *
    * @example
    * // GLSL declaration
    * uniform mat3 czm_normal3D;
    *
    * // Example
    * vec3 eyeNormal = czm_normal3D * normal;
    */
    "czm_normal3D": AutomaticUniform(
        size : 1,
        datatype: UniformDataType.FloatMatrix3,
        getValue: { (uniformState: UniformState) -> UniformSourceType in
            return uniformState.normal3D
        }
    ),
    
    /**
    * An automatic GLSL uniform representing a 3x3 normal transformation matrix that
    * transforms normal vectors in eye coordinates to model coordinates.  This is
    * the opposite of the transform provided by {@link czm_normal}.
    *
    * @alias czm_inverseNormal
    * @glslUniform
    *
    * @see UniformState#inverseNormal
    * @see czm_normal
    * @see czm_modelView
    * @see czm_inverseView
    *
    * @example
    * // GLSL declaration
    * uniform mat3 czm_inverseNormal;
    *
    * // Example
    * vec3 normalMC = czm_inverseNormal * normalEC;
    */
    /*
    czm_inverseNormal : new AutomaticUniform({
    size : 1,
    datatype : WebGLRenderingContext.FLOAT_MAT3,
    getValue : function(uniformState) {
    return uniformState.inverseNormal; as Any
    }
    }),
    
    /**
    * An automatic GLSL uniform representing a 3x3 normal transformation matrix that
    * transforms normal vectors in eye coordinates to 3D model coordinates.  This is
    * the opposite of the transform provided by {@link czm_normal}.
    * In 3D mode, this is identical to
    * {@link czm_inverseNormal}, but in 2D and Columbus View it represents the inverse normal transformation
    * matrix as if the camera were at an equivalent location in 3D mode.  This is useful for lighting
    * 2D and Columbus View in the same way that 3D is lit.
    *
    * @alias czm_inverseNormal3D
    * @glslUniform
    *
    * @see UniformState#inverseNormal3D
    * @see czm_inverseNormal
    *
    * @example
    * // GLSL declaration
    * uniform mat3 czm_inverseNormal3D;
    *
    * // Example
    * vec3 normalMC = czm_inverseNormal3D * normalEC;
    */
    czm_inverseNormal3D : new AutomaticUniform({
    size : 1,
    datatype : WebGLRenderingContext.FLOAT_MAT3,
    getValue : function(uniformState) {
    return uniformState.inverseNormal3D; as Any
    }
    }),
    
    /**
    * An automatic GLSL uniform containing height (<code>x</code>) and height squared (<code>y</code>)
    *  of the eye (camera) in the 2D scene in meters.
    *
    * @alias czm_eyeHeight2D
    * @glslUniform
    *
    * @see UniformState#eyeHeight2D
    */
    czm_eyeHeight2D : new AutomaticUniform({
    size : 1,
    datatype : WebGLRenderingContext.FLOAT_VEC2,
    getValue : function(uniformState) {
    return uniformState.eyeHeight2D; as Any
    }
    }),
    */
    /**
    * An automatic GLSL uniform containing the near distance (<code>x</code>) and the far distance (<code>y</code>)
    * of the frustum defined by the camera.  This is the largest possible frustum, not an individual
    * frustum used for multi-frustum rendering.
    *
    * @alias czm_entireFrustum
    * @glslUniform
    *
    * @see UniformState#entireFrustum
    * @see czm_currentFrustum
    *
    * @example
    * // GLSL declaration
    * uniform vec2 czm_entireFrustum;
    *
    * // Example
    * float frustumLength = czm_entireFrustum.y - czm_entireFrustum.x;
    */
    "czm_entireFrustum": AutomaticUniform(
        size: 1,
        datatype: .FloatVec2,
        getValue: { (uniformState: UniformState) -> UniformSourceType in
            return uniformState.entireFrustum
        }
    ),
    /*
    /**
    * An automatic GLSL uniform containing the near distance (<code>x</code>) and the far distance (<code>y</code>)
    * of the frustum defined by the camera.  This is the individual
    * frustum used for multi-frustum rendering.
    *
    * @alias czm_currentFrustum
    * @glslUniform
    *
    * @see UniformState#currentFrustum
    * @see czm_entireFrustum
    *
    * @example
    * // GLSL declaration
    * uniform vec2 czm_currentFrustum;
    *
    * // Example
    * float frustumLength = czm_currentFrustum.y - czm_currentFrustum.x;
    */
    czm_currentFrustum : new AutomaticUniform({
    size : 1,
    datatype : WebGLRenderingContext.FLOAT_VEC2,
    getValue : function(uniformState) {
    return uniformState.currentFrustum; as Any
    }
    }),
    
    /**
             * The distances to the frustum planes. The top, bottom, left and right distances are
             * the x, y, z, and w components, respectively.
             *
             * @alias czm_frustumPlanes
             * @glslUniform
             */
            czm_frustumPlanes : new AutomaticUniform({
                size : 1,
                datatype : WebGLConstants.FLOAT_VEC4,
                getValue : function(uniformState) {
                    return uniformState.frustumPlanes;
                }
            }),
    
            /**
    * An automatic GLSL uniform representing the sun position in world coordinates.
    *
    * @alias czm_sunPositionWC
    * @glslUniform
    *
    * @see UniformState#sunPositionWC
    * @see czm_sunPositionColumbusView
    * @see czm_sunDirectionWC
    *
    * @example
    * // GLSL declaration
    * uniform vec3 czm_sunPositionWC;
    */
    czm_sunPositionWC : new AutomaticUniform({
    size : 1,
    datatype : WebGLRenderingContext.FLOAT_VEC3,
    getValue : function(uniformState) {
    return uniformState.sunPositionWC; as Any
    }
    }),
    
    /**
    * An automatic GLSL uniform representing the sun position in Columbus view world coordinates.
    *
    * @alias czm_sunPositionColumbusView
    * @glslUniform
    *
    * @see UniformState#sunPositionColumbusView
    * @see czm_sunPositionWC
    *
    * @example
    * // GLSL declaration
    * uniform vec3 czm_sunPositionColumbusView;
    */
    czm_sunPositionColumbusView : new AutomaticUniform({
    size : 1,
    datatype : WebGLRenderingContext.FLOAT_VEC3,
    getValue : function(uniformState) {
    return uniformState.sunPositionColumbusView; as Any
    }
    }),
    */
    /**
    * An automatic GLSL uniform representing the normalized direction to the sun in eye coordinates.
    * This is commonly used for directional lighting computations.
    *
    * @alias czm_sunDirectionEC
    * @glslUniform
    *
    * @see UniformState#sunDirectionEC
    * @see czm_moonDirectionEC
    * @see czm_sunDirectionWC
    *
    * @example
    * // GLSL declaration
    * uniform vec3 czm_sunDirectionEC;
    *
    * // Example
    * float diffuse = max(dot(czm_sunDirectionEC, normalEC), 0.0);
    */
    "czm_sunDirectionEC": AutomaticUniform(
        size: 1,
        datatype: UniformDataType.FloatVec3,
        getValue: { (uniformState: UniformState) -> UniformSourceType in
            return uniformState.sunDirectionEC
        }
    ),
    
    /**
    * An automatic GLSL uniform representing the normalized direction to the sun in world coordinates.
    * This is commonly used for directional lighting computations.
    *
    * @alias czm_sunDirectionWC
    * @glslUniform
    *
    * @see UniformState#sunDirectionWC
    * @see czm_sunPositionWC
    * @see czm_sunDirectionEC
    *
    * @example
    * // GLSL declaration
    * uniform vec3 czm_sunDirectionWC;
    */
    "czm_sunDirectionWC": AutomaticUniform(
        size: 1,
        datatype: .FloatVec3,
        getValue: { (uniformState: UniformState) -> UniformSourceType in
            return uniformState.sunDirectionWC
        }
    ),
    
    /**
    * An automatic GLSL uniform representing the normalized direction to the moon in eye coordinates.
    * This is commonly used for directional lighting computations.
    *
    * @alias czm_moonDirectionEC
    * @glslUniform
    *
    * @see UniformState#moonDirectionEC
    * @see czm_sunDirectionEC
    *
    * @example
    * // GLSL declaration
    * uniform vec3 czm_moonDirectionEC;
    *
    * // Example
    * float diffuse = max(dot(czm_moonDirectionEC, normalEC), 0.0);
    */
    "czm_moonDirectionEC": AutomaticUniform(
        size : 1,
        datatype: UniformDataType.FloatVec3,
        getValue: { (uniformState: UniformState) -> UniformSourceType in
            return uniformState.moonDirectionEC
        }
    ),
    /*
    /**
    * An automatic GLSL uniform representing the high bits of the camera position in model
    * coordinates.  This is used for GPU RTE to eliminate jittering artifacts when rendering
    * as described in {@link http://blogs.agi.com/insight3d/index.php/2008/09/03/precisions-precisions/|Precisions, Precisions}.
    *
    * @alias czm_encodedCameraPositionMCHigh
    * @glslUniform
    *
    * @see czm_encodedCameraPositionMCLow
    * @see czm_modelViewRelativeToEye
    * @see czm_modelViewProjectionRelativeToEye
    *
    * @example
    * // GLSL declaration
    * uniform vec3 czm_encodedCameraPositionMCHigh;
    */
    czm_encodedCameraPositionMCHigh : new AutomaticUniform({
    size : 1,
    datatype : WebGLRenderingContext.FLOAT_VEC3,
    getValue : function(uniformState) {
    return uniformState.encodedCameraPositionMCHigh; as Any
    }
    }),
    
    /**
    * An automatic GLSL uniform representing the low bits of the camera position in model
    * coordinates.  This is used for GPU RTE to eliminate jittering artifacts when rendering
    * as described in {@link http://blogs.agi.com/insight3d/index.php/2008/09/03/precisions-precisions/|Precisions, Precisions}.
    *
    * @alias czm_encodedCameraPositionMCLow
    * @glslUniform
    *
    * @see czm_encodedCameraPositionMCHigh
    * @see czm_modelViewRelativeToEye
    * @see czm_modelViewProjectionRelativeToEye
    *
    * @example
    * // GLSL declaration
    * uniform vec3 czm_encodedCameraPositionMCLow;
    */
    czm_encodedCameraPositionMCLow : new AutomaticUniform({
    size : 1,
    datatype : WebGLRenderingContext.FLOAT_VEC3,
    getValue : function(uniformState) {
    return uniformState.encodedCameraPositionMCLow; as Any
    }
    }),
    */
    /**
    * An automatic GLSL uniform representing the position of the viewer (camera) in world coordinates.
    *
    * @alias czm_viewerPositionWC
    * @glslUniform
    *
    * @example
    * // GLSL declaration
    * uniform vec3 czm_viewerPositionWC;
    */
    "czm_viewerPositionWC":  AutomaticUniform(
        size : 1,
        datatype : .FloatVec3,
        getValue : { (uniformState: UniformState) -> UniformSourceType in
            return uniformState.inverseView.translation
        }
    ),
    
    /**
    * An automatic GLSL uniform representing the frame number. This uniform is automatically incremented
    * every frame.
    *
    * @alias czm_frameNumber
    * @glslUniform
    *
    * @example
    * // GLSL declaration
    * uniform float czm_frameNumber;
    */
    "czm_frameNumber": AutomaticUniform(
        size: 1,
        datatype : UniformDataType.FloatVec1,
        getValue: { (uniformState: UniformState) -> UniformSourceType in
            return Float(uniformState.frameState.frameNumber)
        }
    ),
    
    /**
    * An automatic GLSL uniform representing the current morph transition time between
    * 2D/Columbus View and 3D, with 0.0 being 2D or Columbus View and 1.0 being 3D.
    *
    * @alias czm_morphTime
    * @glslUniform
    *
    * @example
    * // GLSL declaration
    * uniform float czm_morphTime;
    *
    * // Example
    * vec4 p = czm_columbusViewMorph(position2D, position3D, czm_morphTime);
    */
    "czm_morphTime": AutomaticUniform(
        size: 1,
        datatype: UniformDataType.FloatVec1,
        getValue: { (uniformState: UniformState) -> UniformSourceType in
            return uniformState.frameState.morphTime
        }
    ),
    
    /*
    
    
    /**
    * An automatic GLSL uniform representing the current {@link SceneMode}, expressed
    * as a float.
    *
    * @alias czm_sceneMode
    * @glslUniform
    *
    * @see czm_sceneMode2D
    * @see czm_sceneModeColumbusView
    * @see czm_sceneMode3D
    * @see czm_sceneModeMorphing
    *
    * @example
    * // GLSL declaration
    * uniform float czm_sceneMode;
    *
    * // Example
    * if (czm_sceneMode == czm_sceneMode2D)
    * {
    *     eyeHeightSq = czm_eyeHeight2D.y;
    * }
    */
    czm_sceneMode : new AutomaticUniform({
    size : 1,
    datatype : WebGLRenderingContext.FLOAT,
    getValue : function(uniformState) {
    return uniformState.frameState.mode; as Any
    }
    }),
    */
    /**
    * An automatic GLSL uniform representing a 3x3 rotation matrix that transforms
    * from True Equator Mean Equinox (TEME) axes to the pseudo-fixed axes at the current scene time.
    *
    * @alias czm_temeToPseudoFixed
    * @glslUniform
    *
    * @see UniformState#temeToPseudoFixedMatrix
    * @see Transforms.computeTemeToPseudoFixedMatrix
    *
    * @example
    * // GLSL declaration
    * uniform mat3 czm_temeToPseudoFixed;
    *
    * // Example
    * vec3 pseudoFixed = czm_temeToPseudoFixed * teme;
    */
    "czm_temeToPseudoFixed": AutomaticUniform(
        size : 1,
        datatype : .FloatMatrix3,
        getValue: { (uniformState: UniformState) -> UniformSourceType in
            uniformState.temeToPseudoFixedMatrix
        }
    ),
    /*
    /**
    * An automatic GLSL uniform representing the ratio of canvas coordinate space to canvas pixel space.
    *
    * @alias czm_resolutionScale
    * @glslUniform
    *
    * @example
    * uniform float czm_resolutionScale;
    */
    czm_resolutionScale : new AutomaticUniform({
    size : 1,
    datatype : WebGLRenderingContext.FLOAT,
    getValue : function(uniformState) {
    return uniformState.resolutionScale; as Any
    }
    })
    };*/


    /**
     * An automatic GLSL uniform scalar used to mix a color with the fog color based on the distance to the camera.
     *
     * @alias czm_fogDensity
     * @glslUniform
     *
     * @see czm_fog
     */
    "czm_fogDensity": AutomaticUniform(
        size : 1,
        datatype: UniformDataType.FloatVec1,
        getValue: { (uniformState: UniformState) -> UniformSourceType in
            return 0.0//Float(uniformState.fogDensity)
        }
    )

]