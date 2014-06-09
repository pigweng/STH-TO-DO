import java.io.InputStream;   
import java.io.PrintStream;   
  
import org.apache.commons.net.telnet.EchoOptionHandler;   
import org.apache.commons.net.telnet.SuppressGAOptionHandler;   
import org.apache.commons.net.telnet.TelnetClient;   
import org.apache.commons.net.telnet.TerminalTypeOptionHandler;   
  
/**  
* 使用apache的commons-net包模拟telnet登录  
*/  
public class TestTelnet {   
  
    private TelnetClient telnet = null;   
    private InputStream in;   
    private PrintStream out;   
    private char prompt = '#';  //linux提示符   
       
    /**  
    * 登录linux  
    * @param server  
    * @param user  
    * @param password  
    */  
    public TestTelnet(String server, String user, String password) {   
        try {   
            // Connect to the specified server   
            telnet = new TelnetClient();   
            TerminalTypeOptionHandler ttopt = new TerminalTypeOptionHandler(   
                    "VT100", false, false, true, false);   
            EchoOptionHandler echoopt = new EchoOptionHandler(true, false,   
                    true, false);   
            SuppressGAOptionHandler gaopt = new SuppressGAOptionHandler(true,   
                    true, true, true);   
  
            telnet.addOptionHandler(ttopt);   
            telnet.addOptionHandler(echoopt);   
            telnet.addOptionHandler(gaopt);   
  
            telnet.connect(server, 23);   
  
            // Get input and output stream references   
            in = telnet.getInputStream();   
  
            out = new PrintStream(telnet.getOutputStream());   
  
            // Log the user on   
            readUntil("login: ");   
            write(user);   
  
            readUntil("Password: ");   
            write(password);   
  
            // Advance to a prompt   
            readUntil("$" + " ");   
  
            // readUntil("$" + "su = root");   
            // write("su - root");   
  
        } catch (Exception e) {   
            e.printStackTrace();   
        }   
    }   
  
    /**  
     * 改变当前登录用户  
     * @param user 用户名  
     * @param password 密码  
     * @param serTile linux用户提示符  
     * @return  
     */  
    public String suUser(String user, String password, String userTitle) {   
        // System.out.println("改变当前用户：");   
        write("su - " + user);   
        // System.out.println("准备读取返回的流，看是不是可以继续录入密码了：");   
        readUntil("密码：");// 有可能不是中文，先用telnet命令测试下   
        // System.out.println("返回信息提示可以录入密码，才开始录密码：");   
        write(password);   
        return readUntil(userTitle + " ");   
    }   
  
    /**  
     * 读取流信息  
     * @param pattern 流读取时的结束字符  
     * @return  
     */  
    public String readUntil(String pattern) {   
        try {   
            char lastChar = pattern.charAt(pattern.length() - 1);   
            // System.out.println("当前流的字符集："+new   
            // InputStreamReader(in).getEncoding());   
            StringBuffer sb = new StringBuffer();   
            byte[] buff = new byte[1024];   
            int ret_read = 0;   
            String str = "";   
            do {   
                ret_read = in.read(buff);   
                if (ret_read > 0) {   
                    // 把读取流的字符转码，可以在linux机子上用echo $LANG查看系统是什么编码   
                    String v = new String(buff, 0, ret_read, "UTF-8");   
                    str = str + v;   
                    // System.out.println("debug:"+str+"========"+pattern);   
                    if (str.endsWith(pattern)) {   
                        // System.out.println("退出:"+str+"========"+pattern);   
                        break;   
                    }   
                }   
  
            } while (ret_read >= 0);   
            return str;   
        } catch (Exception e) {   
            e.printStackTrace();   
        }   
        return null;   
    }   
  
    /**  
     * 向流中发送信息  
     * @param value  
     */  
    public void write(String value) {   
        try {   
            out.println(value);   
            out.flush();   
            System.out.println("录入命令:" + value);   
        } catch (Exception e) {   
            e.printStackTrace();   
        }   
    }   
  
    /**  
     * 运行命令，默认linux提示符是'$'  
     * @param command 命令  
     * @return  
     */  
    public String sendCommand(String command) {   
        try {   
            prompt = '$';   
            write(command);   
            return readUntil(prompt + " ");   
        } catch (Exception e) {   
            e.printStackTrace();   
        }   
        return null;   
    }   
  
    /**  
     * 运行命令，默认linux提示符是'$'  
     * @param command 命令  
     * @param userTitle linux提示符  
     * @return  
     */  
    public String sendCommand(String command, char userTitle) {   
        try {   
            prompt = userTitle;   
            write(command);   
            return readUntil(prompt + " ");   
        } catch (Exception e) {   
            e.printStackTrace();   
        }   
        return null;   
    }   
  
    /**  
     * 释放连接  
     */  
    public void disconnect() {   
        try {   
            telnet.disconnect();   
        } catch (Exception e) {   
            e.printStackTrace();   
        }   
    }   
       
    /**  
     * @param args  
     */  
    public static void main(String[] args) {   
        try {   
            TestTelnet telnet = new TestTelnet("192.168.0.1", "zhsoft", "rootroot");   
            // 使用--color=no屏蔽ls命令的颜色，要不会有乱码   
            String reStr = telnet.sendCommand("ls --color=no");   
            System.out.println(reStr.replaceFirst("ls --color=no", ""));   
            telnet.suUser("root", "rootroot", "#");   
            String reStr2 = telnet.sendCommand("ls --color=no", '#');   
            System.out.println(reStr2.replaceFirst("ls --color=no", ""));   
            telnet.disconnect();   
        } catch (Exception e) {   
            e.printStackTrace();   
        }   
    }   
  
}  
