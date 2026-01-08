declare function GetParentResourceName(): string;

declare module "*.jpg";
declare module "*.png";
declare module "*.ogg";

declare module "*.json";
declare module "*.vue" {
    import Vue from 'vue'
    export default Vue
}