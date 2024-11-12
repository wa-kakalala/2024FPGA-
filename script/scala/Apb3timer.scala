package vexriscv.yyrwkk

import spinal.core._
import spinal.lib._
import spinal.lib.bus.amba3.apb._
import spinal.lib.bus.misc._

case class Apb3timer(addressWidth: Int, dataWidth: Int) extends Component {
  val apbConfig = Apb3Config(
        addressWidth = addressWidth,  
        dataWidth    = dataWidth     
  )

  val io = new Bundle {
    val apb = slave(Apb3(apbConfig))
    
    val value      = out UInt(dataWidth bits)
    val prescale   = out UInt(dataWidth bits)
    val clear      = out Bool()
    val enable     = out Bool()
    
    val interrupt  = in Bool()  
  }
  
  val busCtrl = Apb3SlaveFactory(io.apb)
  
  val reg_val = busCtrl.createReadWrite(UInt(dataWidth bits),0x00, 0) init(0)
  val reg_pre = busCtrl.createReadWrite(UInt(dataWidth bits),0x04, 0) init(0)
  val reg_cfg = busCtrl.createReadWrite(UInt(dataWidth bits),0x08, 0) init(0)
  val reg_int = busCtrl.createReadWrite(UInt(dataWidth bits),0x0C, 0) init(0)

  io.value    := reg_val
  io.prescale := reg_pre
  io.clear    := reg_cfg(1)
  io.enable   := reg_cfg(0)

  reg_int(0) := io.interrupt

  when( reg_cfg(1) === True ) {
    reg_cfg(1) := False
  }
}

// object Apb3timerVerilog extends App {
//   SpinalVerilog(new Apb3timer(4,32))
// }


