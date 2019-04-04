package com.genome2d.project;

import com.genome2d.callbacks.GCallback.GCallback0;
import com.genome2d.callbacks.GCallback.GCallback2;
import com.genome2d.debug.GDebug;
import com.genome2d.macros.MGDebug;
import com.genome2d.assets.GAssetManager;
import com.genome2d.context.GContextConfig;
import com.genome2d.assets.GAsset;
import com.genome2d.assets.GStaticAssetManager;
import com.genome2d.geom.GRectangle;
#if cs
import unityengine.*;
import com.genome2d.input.GMouseInputType;
#end

#if !cs
class GProject {
#else
@:nativeGen
class GProject extends MonoBehaviour {
#end
    #if cs
    public var onFrame(default,null):GCallback0;
    public var onMouse(default,null):GCallback2<String, Int>;
    #end

    private var g2d_genome:Genome2D;
    public function getGenome():Genome2D {
        return g2d_genome;
    }

    private var g2d_config:GProjectConfig;

    private var g2d_assetManager:GAssetManager;

    #if !cs
    public function new(p_config:GProjectConfig) {
        g2d_config = p_config;

        g2d_genome = Genome2D.getInstance();
        if (g2d_config.initGenome) {
            initGenome();
        } else {
            init();
        }
    }
    #else
    public function Start() {
        GDebug.info("Starting project.");
        onFrame = new GCallback0();
        onMouse = new GCallback2<String, Int>();

        var contextConfig:GContextConfig = new GContextConfig(this, new GRectangle(0,0,Screen.width,Screen.height));
        g2d_config = new GProjectConfig(contextConfig);

        g2d_genome = Genome2D.getInstance();
        if (g2d_config.initGenome) {
            initGenome();
        } else {
            init();
        }
    }

    private var g2d_mouseInitialized:Bool = false;
    private var g2d_lastMouseX:Float;
    private var g2d_lastMouseY:Float;

    public function Update() {
        if (Input.GetMouseButtonDown(0)) {
            onMouse.dispatch(GMouseInputType.MOUSE_DOWN, 0);
        } else if (Input.GetMouseButtonUp(0)) {
            onMouse.dispatch(GMouseInputType.MOUSE_UP, 0);
        } else {
            if (!g2d_mouseInitialized) {
                g2d_mouseInitialized = true;
            } else {
                if (g2d_lastMouseX != Input.mousePosition.x || g2d_lastMouseY != Input.mousePosition.y) {
                    onMouse.dispatch(GMouseInputType.MOUSE_MOVE, -1);
                }
            }
        }
        g2d_lastMouseX = Input.mousePosition.x;
        g2d_lastMouseX = Input.mousePosition.y;
    }

    public function OnPostRender() {
        onFrame.dispatch();
    }
    #end
    /**
     *  Initialize Genome2D
     **/
    private function initGenome():Void {
        GDebug.info("initGenome");
        g2d_genome.onFailed.addOnce(genomeFailed_handler);
        g2d_genome.onInitialized.addOnce(genomeInitialized_handler);
        g2d_genome.init(g2d_config.contextConfig);
    }

    private function init():Void {
    }

    /**
     *  Handlers
     **/
    private function genomeInitialized_handler():Void {
        GDebug.info("genomeInitialized");
        g2d_assetManager = new GAssetManager();
        init();
    }

    private function genomeFailed_handler(p_msg:String):Void {
        GDebug.error("genomeFailed", p_msg);
    }
}
