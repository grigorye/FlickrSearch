//
//  ThrowingResult.swift
//  FlickrSearch
//
//  Created by Grigory Entin on 29.03.2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//


/**
 Simpler? alternative to `Result<T>` and `(Error?, T?)`.
 
 - returns:
Value for successfull result.
 
 - throws:
Error for failing result.
 
 - SeeAlso:
 `dispatch` family of functions.
 */
typealias ThrowingResult<T> = () throws -> T

func dispatch<Input, Result>(_ dispatchInput: () throws -> Input, _ completion: @escaping (() throws -> Result) -> Void, follow: (Input) -> Void) {
    do {
        let input = try dispatchInput()
        follow(input)
    } catch {
        completion({ throw error })
    }
}

func dispatch<Input>(_ dispatchInput: () throws -> Input, `catch`: (Error) -> Void, or follow: ((Input) -> Void)? = nil) {
    do {
        let input = try dispatchInput()
        follow?(input)
    } catch {
        `catch`(error)
    }
}

func dispatch<Result>(_ completion: @escaping (() throws -> Result) -> Void, try block: ((Result) -> Void) throws -> Void) {
    do {
        try block({ result in
            completion({ return result })
        })
    } catch {
        completion({ throw error })
    }
}

func trap<IgnoredInput, Result>(_ dispatchIgnoredInput: () throws -> IgnoredInput, _ completion: @escaping (() throws -> Result) -> Void, follow: () -> Void) {
    do {
        _ = try dispatchIgnoredInput()
        follow()
    } catch {
        completion({ throw error })
    }
}

func trap<IgnoredInput, Result>(_ dispatchIgnoredInput: () throws -> IgnoredInput, _ completion: @escaping (() throws -> Result) -> Void, value: Result) {
    do {
        _ = try dispatchIgnoredInput()
        completion({ return value })
    } catch {
        completion({ throw error })
    }
}

