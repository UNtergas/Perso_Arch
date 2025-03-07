import Window from "./Window.js"
import Gdk from "gi://Gdk"
import Gtk from "gi://Gtk?version=3.0"
import options from "../../options.js"

const TARGET = [Gtk.TargetEntry.new("text/plain", Gtk.TargetFlags.SAME_APP, 0)]
const scale = (size) => (options.overview.scale / 100) * size
const hyprland = await Service.import("hyprland")

const dispatch = (args) => hyprland.messageAsync(`dispatch ${args}`)

const size = (id) => {
  const def = { h: 1200, w: 1600}
  const ws = hyprland.getWorkspace(id)
  if (!ws)
    return def

  const mon = hyprland.getMonitor(ws.monitorID)
  return mon ? { h: mon.height, w: mon.width } : def
}

export default (id) => Widget.Box({
  attribute: { id },
  tooltipText: `${id}`,
  class_name: "workspace",
  vpack: "center",
  css: `
        max-width : ${scale(size(id).w)};px;
        max-height : ${scale(size(id).h)};px;
    `,
  setup: box => box.hook(hyprland, () => {
    box.toggleClassName("active", hyprland.active.workspace.id === id)
  }),
  child: Widget.EventBox({
    expand: true,
    on_primary_click: () => {
      App.closeWindow("overview")
      dispatch(`workspace ${id}`)
    },
    setup: eventbox => {
      eventbox.drag_dest_set(Gtk.DestDefaults.ALL, TARGET, Gdk.DragAction.COPY)
      eventbox.connect("drag-data-received", (_w, _c, _x, _y, data) => {
        const address = new TextDecoder().decode(data.get_data())
        dispatch(`movetoworkspacesilent ${id},address:${address}`)
      })
    },
    child: Widget.Fixed().hook(hyprland, fixed => {
      fixed.get_children().forEach(ch => ch.destroy())
      hyprland.clients
        .filter(({ workspace }) => workspace.id === id)
        .forEach(c => {
          const x = c.at[0] - (hyprland.getMonitor(c.monitor)?.x || 0)
          const y = c.at[1] - (hyprland.getMonitor(c.monitor)?.y || 0)
          c.mapped && fixed.put(Window(c), scale(x), scale(y))
        })
      fixed.show_all()
    }, "notify::clients"),
  }),
})
