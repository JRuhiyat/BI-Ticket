// controllers/index.js
// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "./application"
import UploadController from "./upload_controller"

application.register("upload", UploadController)