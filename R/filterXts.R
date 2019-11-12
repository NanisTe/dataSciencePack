#' Filter data.frame with xts syntax
#'
#' This function converts your data.frame which must have a cloumn with POSIXct
#'   values into an xts object and filters the xts object according to the
#'   argument xtsstring. It converts the filtered xts back into a data.frame
#'   and returns it.
#'
#' @importFrom xts xts
#' @importFrom zoo index
#' @importFrom lubridate with_tz
#' @importFrom dplyr inner_join
#'
#' @export
#' @param df a data.frame with at least one column of POSIXct values.
#' @param xtsstring a string which describes the desired date range to be
#'   filtered out (see \code{\link[xts]{xts}}).
#' @param tzone give the timezone format to be used. default = "UTC"
#' @param by_colname give the column name of the datetime column to be used.
#' @return a filtered data.frame which is a subset of the original data.frame \code{df}
filterXts <- function(df, xtsstring, tzone="UTC", by_colname = "Datetime") {

  orig_tz <- tz(df[,by_colname])
  if(is.null(by_colname)) by_colname=names(df)[1]
  # check if by_colname is string and if it is part of colnames(df)
  if(!is.element(by_colname,colnames(df))) stop(paste0("filterXts: Argument by_colname= \"",by_colname,"\" is not a column name of dataframe df."))
  df[,by_colname]<-lubridate::with_tz(df[,by_colname],tzone = tzone)
  dates.xts <- xts::xts(df[,by_colname], order.by = df[[1]])
  indices <- zoo::index(dates.xts[xtsstring])
  filtered <- data.frame(Col_1 = indices)

  #' Prepare a named character to be used in the by = statement in the join function.
  #' Its name has to be the column name of the matching column from original
  #'

  #' Creating a named Vector for inner_join its by argument
  join.by <- "Col_1"
  names(join.by) <- names(df[by_colname])

  ret <- dplyr::inner_join(df, filtered, by = c(join.by))
  ret <- lubridate::with_tz(df[,by_colname],tzone = orig_tz)

  return(ret)
}
