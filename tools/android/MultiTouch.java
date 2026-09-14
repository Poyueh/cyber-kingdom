import android.os.SystemClock;
import android.view.InputDevice;
import android.view.InputEvent;
import android.view.MotionEvent;
import java.lang.reflect.Method;

/** External shell test driver: injects a second finger while the first stays down. */
public final class MultiTouch {
    static Object manager;
    static Method inject;
    static long down;
    static float[][] points;
    static void send(int action, int count) throws Exception {
        MotionEvent.PointerProperties[] properties = new MotionEvent.PointerProperties[count];
        MotionEvent.PointerCoords[] coords = new MotionEvent.PointerCoords[count];
        for (int i=0; i<count; i++) {
            properties[i] = new MotionEvent.PointerProperties();
            properties[i].id=i;
            properties[i].toolType=MotionEvent.TOOL_TYPE_FINGER;
            coords[i] = new MotionEvent.PointerCoords();
            coords[i].x=points[i][0]; coords[i].y=points[i][1];
            coords[i].pressure=1; coords[i].size=1;
        }
        MotionEvent event=MotionEvent.obtain(down,SystemClock.uptimeMillis(),action,count,
            properties,coords,0,0,1,1,0,0,InputDevice.SOURCE_TOUCHSCREEN,0);
        try {
            if (!((Boolean)inject.invoke(manager,event,2))) throw new IllegalStateException("Input rejected");
            System.out.println("accepted action="+action+" pointers="+count+" elapsed="+(SystemClock.uptimeMillis()-down));
        } finally { event.recycle(); }
    }
    public static void main(String[] args) throws Exception {
        if(args.length!=7 && args.length!=9) throw new IllegalArgumentException("x1 y1 x2 y2 lead_ms overlap_ms tail_ms [pause_x pause_y]");
        points=new float[][]{{Float.parseFloat(args[0]),Float.parseFloat(args[1])},{Float.parseFloat(args[2]),Float.parseFloat(args[3])},{args.length==9?Float.parseFloat(args[7]):0,args.length==9?Float.parseFloat(args[8]):0}};
        Class<?> type=Class.forName("android.hardware.input.InputManagerGlobal");
        manager=type.getMethod("getInstance").invoke(null);
        inject=type.getMethod("injectInputEvent",InputEvent.class,int.class);
        down=SystemClock.uptimeMillis();
        boolean completed=false;
        try {
            send(MotionEvent.ACTION_DOWN,1);
            SystemClock.sleep(Long.parseLong(args[4]));
            send(MotionEvent.ACTION_POINTER_DOWN | (1 << MotionEvent.ACTION_POINTER_INDEX_SHIFT),2);
            SystemClock.sleep(Long.parseLong(args[5]));
            if(args.length==9) {
                send(MotionEvent.ACTION_POINTER_DOWN | (2 << MotionEvent.ACTION_POINTER_INDEX_SHIFT),3);
                SystemClock.sleep(80);
                send(MotionEvent.ACTION_POINTER_UP | (2 << MotionEvent.ACTION_POINTER_INDEX_SHIFT),3);
            }
            send(MotionEvent.ACTION_POINTER_UP | (1 << MotionEvent.ACTION_POINTER_INDEX_SHIFT),2);
            SystemClock.sleep(Long.parseLong(args[6]));
            send(MotionEvent.ACTION_UP,1);
            completed=true;
        } finally {
            if(!completed) {
                try { send(MotionEvent.ACTION_CANCEL,1); }
                catch(Exception cleanup) { System.err.println("Cancel after failure: "+cleanup); }
            }
        }
    }
}
