/*
 * Type definitions for SimpleLightbox 2.12.1
 * Project: https://github.com/andreknieriem/simplelightbox https://simplelightbox.com/
 * Definitions by: SAITOU Keita <https://github.com/yonta>
 * Definitions: https://github.com/DefinitelyTyped/DefinitelyTyped
 * TypeScript Version 4.9.5
 */

declare module "simplelightbox" {
  type SimpleLightboxOptions = {
    readonly sourceAttr?: string
    readonly overlay?: boolean
    readonly overlayOpacity?: number
    readonly spinner?: boolean
    readonly nav?: boolean
    readonly navText?: string[]
    readonly captions?: boolean
    readonly captionDelay?: number
    readonly captionSelector?: string | (() => HTMLElement)
    readonly captionType?: string
    readonly captionsData?: string
    readonly captionPosition?: string
    readonly captionClass?: string
    readonly close?: boolean
    readonly closeText?: string
    readonly swipeClose?: boolean
    readonly showCounter?: boolean
    readonly fileExt?: false | RegExp
    readonly animationSlide?: boolean
    readonly animationSpeed?: number
    readonly preloading?: boolean
    readonly enableKeyboard?: boolean
    readonly loop?: boolean
    readonly rel?: false | string
    readonly docClose?: boolean
    readonly swipeTolerance?: number
    readonly className?: string
    readonly widthRatio?: number
    readonly heightRatio?: number
    readonly scaleImageToRatio?: boolean
    readonly disableRightClick?: boolean
    readonly disableScroll?: boolean
    readonly alertError?: boolean
    readonly alertErrorMessage?: string
    readonly additionalHtml?: boolean
    readonly history?: boolean
    readonly throttleInterval?: number
    readonly doubleTapZoom?: number
    readonly maxZoom?: number
    readonly htmlClass?: string
    readonly rtl?: boolean
    readonly fixedClass?: string
    readonly fadeSpeed?: number
    readonly uniqueImages?: boolean
    readonly focus?: boolean
    readonly scrollZoom?: boolean
    readonly scrollZoomFactor?: number
    readonly download?: boolean
  }

  type SimpleLightboxEvents =
    | "show.simplelightbox"
    | "shown.simplelightbox"
    | "close.simplelightbox"
    | "closed.simplelightbox"
    | "change.simplelightbox"
    | "changed.simplelightbox"
    | "next.simplelightbox"
    | "nextDone.simplelightbox"
    | "prev.simplelightbox"
    | "prevDone.simplelightbox"
    | "nextImageLoaded.simplelightbox"
    | "prevImageLoaded.simplelightbox"
    | "error.simplelightbox"

  type SimpleLightboxData = {
    currentImageIndex: number
    currentImage: HTMLImageElement | null
    globalScrollbarWidth: number
  }

  declare class SimpleLightbox {
    constructor(selectors: string, options: SimpleLightboxOptions)

    on(
      events: SimpleLightboxEvents,
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      callback: (event: any) => any,
    ): SimpleLightbox

    open(elem: Element): void

    close(): void

    next(): void

    prev(): void

    destroy(): void

    refresh(): void

    getLighboxData(): SimpleLightboxData // typo?
  }

  export default SimpleLightbox
}
