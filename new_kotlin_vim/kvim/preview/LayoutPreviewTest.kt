package kvim.preview

import android.view.View
import app.cash.paparazzi.DeviceConfig
import app.cash.paparazzi.Paparazzi
import org.junit.Rule
import org.junit.Test

class LayoutPreviewTest {
    @get:Rule
    val paparazzi = Paparazzi(
        deviceConfig = DeviceConfig.PIXEL_5,
        theme = System.getenv("PREVIEW_THEME") ?: "Theme.Snowpack",
    )

    @Test
    fun preview() {
        val pkg = System.getenv("PREVIEW_PKG")
        val name = System.getenv("PREVIEW_LAYOUT")
        val id = Class.forName("$pkg.R\$layout").getField(name).getInt(null)
        paparazzi.snapshot(paparazzi.inflate<View>(id))
    }
}
